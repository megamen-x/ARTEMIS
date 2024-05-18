import torch
import torchvision.models as models
from torchvision.io import read_image
from ultralytics import YOLO

import numpy as np
import os
import random

from typing import Optional, Union, Tuple

import warnings

warnings.filterwarnings('ignore')

id2label = {
    '0': 'Deer',
    '1': 'Musk Deer',
    '2': 'Roe Deer'
}

label2id = {
    'Deer': '0',
    'Musk Deer': '1',
    'Roe Deer': '2'
}


class CFG:
    device = 'cuda' if torch.cuda.is_available() else 'cpu'


def seed_everything(seed=42):
    random.seed(seed)
    os.environ['PYTHONHASHSEED'] = str(seed)
    np.random.seed(seed)
    torch.manual_seed(seed)
    torch.cuda.manual_seed_all(seed)
    torch.backends.cudnn.deterministic = True
    torch.backends.cudnn.benchmark = False


def load_model(
        num_classes: int,
        path_to_model: Optional[str] = None,
        pretrained: bool = False,
) -> models:
    if not pretrained and path_to_model is None:
        raise ValueError("'path_to_model' cannot set to None, when 'pretrained' set to False.")

    loaded_model = models.efficientnet_v2_s(pretrained=pretrained)
    in_features = loaded_model.classifier[1].in_features
    loaded_model.classifier[1] = torch.nn.Linear(in_features, num_classes, bias=True)

    if not pretrained:
        loaded_model.load_state_dict(torch.load(path_to_model, map_location='cpu'))

    return loaded_model


@torch.inference_mode()
def predict(
        model,
        crop_tensor: torch.Tensor,
        return_probs: bool = False
) -> Union[Tuple[str, torch.Tensor], str]:
    model.eval()
    model.to(CFG.device)

    # img = read_image(path_to_image)
    img = crop_tensor.permute(2, 0, 1)
    weights = models.EfficientNet_V2_S_Weights.IMAGENET1K_V1
    preprocess = weights.transforms()

    batch = preprocess(img).unsqueeze(0).to(CFG.device)
    prediction = model(batch).squeeze(0).softmax(0)
    class_id = prediction.argmax().item()

    if return_probs:
        return id2label[str(class_id)], prediction
    return id2label[str(class_id)]


def detections(bbox, classifier_model, path_to_image, verbose=True):
    # yolo_pred = detection_model(path_to_image, verbose=verbose)[0]
    # bbox = yolo_pred.boxes.xyxyn

    preds = []

    image = read_image(path_to_image).permute(1, 2, 0)
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
            pred_label = predict(classifier_model, crop)

            preds.append(pred_label)

            return max(set(preds), key=preds.count)
    else:
        return None