import torch
import torchvision.models as models
from ultralytics import YOLO

import numpy as np
import os
import random

from typing import Optional, Union, Tuple

import warnings
warnings.filterwarnings('ignore')

id2label = {
    '0': 'Олень - Cervus',
    '1': 'Кабарга - Moschus',
    '2': 'Косуля - Capreolus'
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
        cropped_image: np.ndarray,
        return_probs: bool = False
) -> Union[Tuple[int, torch.Tensor], int]:
    model.eval()
    model.to(CFG.device)

    img = torch.from_numpy(cropped_image).permute(2, 0, 1)
    weights = models.EfficientNet_V2_S_Weights.IMAGENET1K_V1
    preprocess = weights.transforms()

    batch = preprocess(img).unsqueeze(0)
    prediction = model(batch).squeeze(0).softmax(0)
    class_id = prediction.argmax().item()

    if return_probs:
        return class_id, prediction
    return class_id


def detections(detection_model, classifier_model, path_to_image, verbose=True):
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
            pred_label = predict(classifier_model, crop)

            preds[pred_label] += 1

        return id2label[str(np.argmax(preds))]
    else:
        return None


if __name__ == '__main__':
    path_to_model = 'model_epoch_11.pt'

    detector = YOLO('best_of_the_best.pt')
    model = load_model(num_classes=3, path_to_model=path_to_model, pretrained=False)

    pred = detections(detector, model, 'test_files/uncropped/org_roe_115.jpg')
    print(pred)