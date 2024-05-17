import cv2
import numpy
from typing import List


def crop(path_to_image: str, yolo_predict) -> numpy.ndarray:
    """
    Get the original image and return cropped image (bbox from yolo v8)
    :param path_to_image: str
    :param yolo_predict: yolo v8 results
    :return: array for cropped image
    """
    image = cv2.imread(path_to_image)
    height, width, _ = image.shape
    try:
        x_min, y_min, x_max, y_max = yolo_predict[0].boxes.xyxyn[0]
        x_min = int(x_min * width)
        y_min = int(y_min * height)
        x_max = int(x_max * width)
        y_max = int(y_max * height)

        w = x_max - x_min
        h = y_max - y_min

        crop_img = yolo_predict[0].orig_img[y_min:y_min + h, x_min:x_min + w]  # np.array
        return crop_img
    except:
        return None


def draw_boxes(path_to_image: str, yolo_predict) -> numpy.ndarray:
    """
    Get the original image and return image with visualized bboxes (coord from yolo v8 predict)
    :param path_to_image: str
    :param yolo_predict: yolo v8 results
    :return: array with visualized bboxes
    """
    image = cv2.imread(path_to_image)
    height, width, _ = image.shape

    try:
        for object_ in yolo_predict[0].boxes.xyxyn:
            x_min, y_min, x_max, y_max = object_
            x_min = int(x_min * width)
            y_min = int(y_min * height)
            x_max = int(x_max * width)
            y_max = int(y_max * height)
            cv2.rectangle(image, (x_min, y_min), (x_max, y_max), (0, 255, 0), 3)  # array here

        return image
    except:
        return image


"""def draw_boxes_from_list(
        path_to_image: str,
        list_yolo_pred: List[float],
        labels: List[float]
) -> numpy.ndarray:

    colors = {'1': (255, 0, 0), '2': (0, 255, 0), '3': (0, 0, 255), '4': (127, 127, 127)}
    image = cv2.imread(path_to_image)
    height, width, _ = image.shape

    try:
        for object_, label_ in zip(list_yolo_pred, labels):
            color = colors[str(int(label_))]
            x_min, y_min, x_max, y_max = object_
            x_min = int(x_min * width)
            y_min = int(y_min * height)
            x_max = int(x_max * width)
            y_max = int(y_max * height)
            cv2.rectangle(image, (x_min, y_min), (x_max, y_max), color, 3)  # array here

        return image
    except:
        return image"""


def draw_boxes_from_list(image_path1, boxes_1, labels1):
    colors = {
        '1': (0, 255, 255),
        '2': (255, 128, 0),
        '3': (0, 255, 0),
        '4': (245, 0, 0)
    }  # длинный, с оружием, без, короткий

    image = cv2.imread(image_path1)
    height, width, _ = image.shape
    print(height, width)

    if boxes_1 is not None:
        for object_, label_ in zip(boxes_1, labels1):
            color = colors[str(int(label_ + 1))]
            x_min, y_min, x_max, y_max = object_
            x_min = int(x_min * width)
            y_min = int(y_min * height)
            x_max = int(x_max * width)
            y_max = int(y_max * height)
            cv2.rectangle(image, (x_min, y_min), (x_max, y_max), color, 3)  # array here

    return image