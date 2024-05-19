import torch
import torch.nn as nn
import torch.nn.functional as F
import torchvision
from torch.utils.data import DataLoader
from sklearn.metrics import f1_score

import numpy as np
import math
import os

from transformers import (
    get_cosine_schedule_with_warmup
)

from tqdm import tqdm
import gc
import open_clip


class CFG:
    model_name = 'convnext_large_d_320'
    model_data = 'laion2b_s29b_b131k_ft_soup'
    seed = 42
    workers = 4
    n_classes = 3
    train_batch_size = 16
    valid_batch_size = 16
    emb_size = 512
    vit_bb_lr = {'8': 1.25e-6, '16': 2.5e-6, '20': 5e-6, '24': 10e-6}
    vit_bb_wd = 1e-3
    hd_lr = 3e-4
    hd_wd = 1e-5
    autocast = True
    n_warmup_steps = 0.02
    n_epochs = 5
    device = 'cuda' if torch.cuda.is_available() else 'cpu'
    s = 30.
    m = .45
    m_min = .05
    acc_steps = 1
    global_step = 0


def seed_everything(seed=42):
    np.random.seed(seed)
    torch.manual_seed(seed)
    torch.cuda.manual_seed(seed)
    os.environ['PYTHONHASHSEED'] = str(seed)
    torch.backends.cudnn.deterministic = True
    torch.backends.cudnn.benchmark = False


class AverageMeter(object):
    def __init__(self, window_size=None):
        self.length = 0
        self.val = 0
        self.avg = 0
        self.sum = 0
        self.count = 0
        self.window_size = window_size

    def reset(self):
        self.length = 0
        self.val = 0
        self.avg = 0
        self.sum = 0
        self.count = 0

    def update(self, val, n=1):
        if self.window_size and (self.count >= self.window_size):
            self.reset()
        self.val = val
        self.sum += val * n
        self.count += n
        self.avg = self.sum / self.count


class Head(nn.Module):
    def __init__(self, hidden_size, emb_size, n_classes):
        super(Head, self).__init__()

        self.emb = nn.Linear(hidden_size, emb_size, bias=False)
        self.arc = ArcMarginProduct_subcenter(emb_size, n_classes)
        self.dropout = Multisample_Dropout()

    def forward(self, x):
        embeddings = self.dropout(x, self.emb)
        output = self.arc(embeddings)

        return output, F.normalize(embeddings)


class ArcMarginProduct_subcenter(nn.Module):
    def __init__(self, in_features, out_features, k=3):
        super().__init__()
        self.weight = nn.Parameter(torch.FloatTensor(out_features * k, in_features))
        self.reset_parameters()
        self.k = k
        self.out_features = out_features

    def reset_parameters(self):
        stdv = 1. / math.sqrt(self.weight.size(1))
        self.weight.data.uniform_(-stdv, stdv)

    def forward(self, features):
        cosine_all = F.linear(F.normalize(features), F.normalize(self.weight))
        cosine_all = cosine_all.view(-1, self.out_features, self.k)
        cosine, _ = torch.max(cosine_all, dim=2)
        return cosine


class Multisample_Dropout(nn.Module):
    def __init__(self):
        super(Multisample_Dropout, self).__init__()
        self.dropout = nn.Dropout(.1)
        self.dropouts = nn.ModuleList([nn.Dropout((i + 1) * .1) for i in range(5)])

    def forward(self, x, module):
        x = self.dropout(x)
        return torch.mean(torch.stack([module(dropout(x)) for dropout in self.dropouts], dim=0), dim=0)


class ArcFaceLossAdaptiveMargin(nn.modules.Module):
    def __init__(self, margins, s=30.0):
        super().__init__()
        self.crit = nn.CrossEntropyLoss()
        self.s = s
        self.margins = margins

    def forward(self, logits, labels, out_dim):
        ms = []
        ms = self.margins[labels.cpu().numpy()]
        cos_m = torch.from_numpy(np.cos(ms)).float().cuda()
        sin_m = torch.from_numpy(np.sin(ms)).float().cuda()
        th = torch.from_numpy(np.cos(math.pi - ms)).float().cuda()
        mm = torch.from_numpy(np.sin(math.pi - ms) * ms).float().cuda()
        labels = F.one_hot(labels, out_dim).float()
        logits = logits.float()
        cosine = logits
        sine = torch.sqrt(1.0 - torch.pow(cosine, 2))
        phi = cosine * cos_m.view(-1, 1) - sine * sin_m.view(-1, 1)
        phi = torch.where(cosine > th.view(-1, 1), phi, cosine - mm.view(-1, 1))
        output = (labels * phi) + ((1.0 - labels) * cosine)
        output *= self.s
        loss = self.crit(output, labels)
        return loss


def ArcFace_criterion(logits_m, target, margins, s, n_classes):
    arc = ArcFaceLossAdaptiveMargin(margins=margins, s=s)
    loss_m = arc(logits_m, target, n_classes)
    return loss_m


def get_parameter_section(parameters, lr=None, wd=None):
    parameter_settings = []

    lr_is_dict = isinstance(lr, dict)
    wd_is_dict = isinstance(wd, dict)

    layer_no = None
    for no, (n, p) in enumerate(parameters):
        for split in n.split('.'):
            if split.isnumeric():
                layer_no = int(split)

        if not layer_no:
            layer_no = 0
        if lr_is_dict:
            for k, v in lr.items():
                if layer_no < int(k):
                    temp_lr = v
                    break
        else:
            temp_lr = lr

        if wd_is_dict:
            for k, v in wd.items():
                if layer_no < int(k):
                    temp_wd = v
                    break
        else:
            temp_wd = wd

        parameter_setting = {"params": p, "lr": temp_lr, "weight_decay": temp_wd}
        parameter_settings.append(parameter_setting)

    return parameter_settings


class Model(nn.Module):
    def __init__(self, vit_backbone, cfg):
        super(Model, self).__init__()

        self.cfg = cfg
        vit_backbone = vit_backbone.visual
        self.img_size = vit_backbone.image_size
        if type(self.img_size) == tuple:
            self.img_size = self.img_size[1]
        hidden_size = vit_backbone(torch.zeros((1, 3, self.img_size, self.img_size))).shape[1]
        self.vit_backbone = vit_backbone
        self.head = Head(hidden_size, self.cfg.emb_size, self.cfg.n_classes)

    def forward(self, x):
        x = self.vit_backbone(x)
        return self.head(x)

    def get_parameters(self):
        parameter_settings = []
        parameter_settings.extend(
            get_parameter_section([(n, p) for n, p in self.vit_backbone.named_parameters()], lr=self.cfg.vit_bb_lr,
                                  wd=self.cfg.vit_bb_wd))

        parameter_settings.extend(
            get_parameter_section([(n, p) for n, p in self.head.named_parameters()], lr=self.cfg.hd_lr,
                                  wd=self.cfg.hd_wd))

        return parameter_settings


def get_lr_groups(param_groups):
    groups = sorted(set([param_g['lr'] for param_g in param_groups]))
    groups = ["{:2e}".format(group) for group in groups]
    return groups


def train(model, train_loader, optimizer, scaler, scheduler, epoch):
    model.train()
    loss_metrics = AverageMeter()
    criterion = ArcFace_criterion
    value_counts = [13159, 1686, 4293]
    tmp = np.sqrt(1 / np.sqrt(value_counts))
    margins = (tmp - tmp.min()) / (tmp.max() - tmp.min()) * CFG.m + CFG.m_min

    bar = tqdm(train_loader, disable=False)
    for step, (images, labels) in enumerate(bar):
        step += 1
        images = images.to(CFG.device, dtype=torch.float)
        labels = labels.to(CFG.device)
        batch_size = labels.size(0)

        with torch.cuda.amp.autocast(enabled=CFG.autocast):
            outputs, _ = model(images)

        loss = criterion(outputs, labels, margins, CFG.s, CFG.n_classes)
        loss_metrics.update(loss.item(), batch_size)
        loss = loss / CFG.acc_steps
        scaler.scale(loss).backward()

        if step % CFG.acc_steps == 0 or step == len(bar):
            scaler.step(optimizer)
            scaler.update()
            optimizer.zero_grad()
            scheduler.step()
            CFG.global_step += 1

        lrs = get_lr_groups(optimizer.param_groups)
        loss_avg = loss_metrics.avg
        bar.set_postfix(loss=loss_avg, epoch=epoch, lrs=lrs, step=CFG.global_step)


def validate(model, loader, return_preds=False):
    model.eval()
    preds = []
    labels = []
    for images, label in tqdm(loader):
        with torch.no_grad():
            outputs = model(images.to(CFG.device))[0].argmax(1).cpu().detach().tolist()
            preds.extend(outputs)
            labels.extend(label)

    metric = f1_score(labels, preds, average='weighted')

    if return_preds:
        return labels, preds, metric
    return metric


if __name__ == '__main__':
    seed_everything(CFG.seed)

    if CFG.device != 'cuda':
        raise RuntimeError('No CUDA GPUs are available. Make sure CUDA is available and do not use finetune without GPUs')

    vit_backbone, _, preprocess = open_clip.create_model_and_transforms(CFG.model_name, pretrained=False)

    path_load_model = '...' # путь до места, где лежит модель
    root_dir = '...' # где хранятся данные
    path_to_save_model = '...' # куда сохранить

    train_folder = torchvision.datasets.ImageFolder(root=f'{root_dir}/train', transform=preprocess)
    valid_folder = torchvision.datasets.ImageFolder(root=f'{root_dir}/valid', transform=preprocess)

    train_dataloader = DataLoader(
        train_folder,
        num_workers=4,
        pin_memory=True,
        batch_size=CFG.train_batch_size,
        shuffle=True
    )

    valid_dataloader = DataLoader(
        valid_folder,
        num_workers=4,
        pin_memory=True,
        batch_size=CFG.valid_batch_size,
        shuffle=False
    )

    model = Model(vit_backbone.cpu(), cfg=CFG).to(CFG.device)
    model.load_state_dict(torch.load(path_load_model, map_location=CFG.device))
    model.eval()

    optimizer = torch.optim.AdamW(model.get_parameters())
    scaler = torch.cuda.amp.GradScaler(enabled=CFG.autocast)
    steps_per_epoch = math.ceil(len(train_dataloader) / CFG.acc_steps)
    num_training_steps = math.ceil(CFG.n_epochs * steps_per_epoch)
    num_warmup_steps = int(num_training_steps * CFG.n_warmup_steps)

    scheduler = get_cosine_schedule_with_warmup(
        optimizer,
        num_training_steps=num_training_steps,
        num_warmup_steps=num_warmup_steps
    )

    CFG.global_step = 0
    for epoch in range(CFG.n_epochs):
        train(model, train_dataloader, optimizer, scaler, scheduler, epoch)
        score = validate(model, valid_dataloader)
        print(f'Epoch = {epoch + 1}, score: {score}')
        torch.save(model.state_dict(),
                   f'{path_to_save_model}/{CFG.model_name}_{CFG.model_data}_{score}.pth')

        gc.collect()
        torch.cuda.empty_cache()
