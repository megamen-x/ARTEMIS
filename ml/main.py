import torch
import torch.nn as nn
import torch.nn.functional as F
from ultralytics import YOLO
from PIL import Image

import numpy as np
import math
import os

import open_clip

import warnings

warnings.filterwarnings('ignore')


class CFG:
    emb_size = 512
    n_classes = 3
    model_name = 'convnext_large_d_320'
    device = 'cuda' if torch.cuda.is_available() else 'cpu'


id2label = {
    '0': 'Олень - Cervus',
    '1': 'Кабарга - Moschus',
    '2': 'Косуля - Capreolus'
}

device = 'cuda' if torch.cuda.is_available() else 'cpu'


def seed_everything(seed=42):
    np.random.seed(seed)
    torch.manual_seed(seed)
    torch.cuda.manual_seed(seed)
    os.environ['PYTHONHASHSEED'] = str(seed)
    torch.backends.cudnn.deterministic = True
    torch.backends.cudnn.benchmark = False


seed_everything()


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
            self.get_parameter_section([(n, p) for n, p in self.vit_backbone.named_parameters()], lr=self.cfg.vit_bb_lr,
                                       wd=self.cfg.vit_bb_wd))

        parameter_settings.extend(
            self.get_parameter_section([(n, p) for n, p in self.head.named_parameters()], lr=self.cfg.hd_lr,
                                       wd=self.cfg.hd_wd))

        return parameter_settings

    def get_parameter_section(self, parameters, lr=None, wd=None):
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


def get_lr_groups(param_groups):
    groups = sorted(set([param_g['lr'] for param_g in param_groups]))
    groups = ["{:2e}".format(group) for group in groups]
    return groups


def load_classifier(cfg, ckpt):
    vit_backbone, _, preproc = open_clip.create_model_and_transforms('convnext_large_d_320', pretrained=False)
    model = Model(vit_backbone, cfg).to(cfg.device)

    model.load_state_dict(torch.load(ckpt, map_location=device))
    model.eval()

    return model, preproc


@torch.inference_mode()
def classifier_predict(classifier_model, image_prepocess, cropped_image, return_probs: bool = False):
    img = Image.fromarray(cropped_image)
    batch = image_prepocess(img).unsqueeze(0).to(device)
    probs = classifier_model(batch)[0].squeeze(0).softmax(0)
    class_id = probs.argmax().item()

    if return_probs:
        return class_id, probs
    return class_id


def detections(detection_model, classifier_model, image_prepocess, path_to_image, verbose=False):
    yolo_pred = detection_model(path_to_image, verbose=verbose)[0]
    bbox = yolo_pred.boxes.xyxyn

    preds = [0, 0, 0]

    image = yolo_pred.orig_img
    height, width, _ = image.shape

    if len(bbox) > 0:
        for box in bbox:
            x_min, y_min, x_max, y_max = box
            x_min = int(x_min * width)
            y_min = int(y_min * height)
            x_max = int(x_max * width)
            y_max = int(y_max * height)

            w = x_max - x_min
            h = y_max - y_min

            crop = image[y_min:y_min + h, x_min:x_min + w]
            pred_label = classifier_predict(classifier_model, image_prepocess, crop)

            preds[pred_label] += 1

        return id2label[str(np.argmax(preds))]
    else:
        return None


if __name__ == '__main__':
    classifier_checkpoint = 'convnext_large_d_320_laion2b_s29b_b131k_ft_soup_0.9752786557219679.pth'
    detector_checkpoint = 'best_of_the_best.pt'
    path_to_image = 'uncropped_test/org_roe_115.jpg'

    classifier, preprocess = load_classifier(CFG, classifier_checkpoint)
    detector = YOLO(detector_checkpoint)

    preds = detections(detector, classifier, preprocess, path_to_image)

    label = preds if preds is not None else 'На фотографии не был найден представитель семейства Оленьих'
    print(label)
