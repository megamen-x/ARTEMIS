import supervision as sv
from ultralytics import YOLO
import csv
import cv2
import os


model = YOLO('./best.pt')

def save_interval(start: int, end: int, overall: int) -> None:
    with open('detections.csv', 'a', newline='') as file:
        writer = csv.writer(file)
        writer.writerow([start, end, overall])

def process_video(source: str, result_name: str = 'result.mp4') -> None:
    video_info = sv.VideoInfo.from_video_path(video_path=source)
    frames_generator = sv.get_video_frames_generator(source_path=source)
    box_annotator = sv.BoundingBoxAnnotator()

    start_interval = None
    interval_ids = set()

    with sv.VideoSink(target_path=result_name, video_info=video_info, codec='h264') as sink:
        for i, frame in enumerate(frames_generator):
            result = model.track(frame, verbose=False, persist=True, agnostic_nms=True)[0]
            if len(result.boxes) and result.boxes.id and start_interval is None:
                print(result.boxes)
                start_interval = int(i / video_info.fps)
                interval_ids.update(result.boxes.id.cpu().tolist())
            elif start_interval:
                print('yes')
                save_interval(start_interval, int(i / video_info.fps), len(interval_ids))
                start_interval = None
                interval_ids = set()
            if len(result.boxes) and result.boxes.id:
                interval_ids.update(result.boxes.id.cpu().tolist())
            detections = sv.Detections.from_ultralytics(result)
            annotated_frame = box_annotator.annotate(
                scene=frame.copy(),
                detections=detections)
            sink.write_frame(frame=annotated_frame)
        if len(interval_ids):
            save_interval(start_interval, int(video_info.total_frames / video_info.fps), len(interval_ids))

def process_image(source: str, result_name: str, annotated_mode: bool=False):
    yolo_predict = model(source)[0]
    if annotated_mode:
        with open(source.split('.')[0] + '.txt', mode='w') as label_file:
            for bbox in yolo_predict.boxes:
                class_bbox = str(int(bbox.cls.cpu().item()))
                coordinates_bbox = ' '.join([str(el) for el in bbox.xyxyn.cpu().tolist()[0]])
                label_file.write(class_bbox + ' ' + coordinates_bbox + '\n')
    detections = sv.Detections.from_ultralytics(yolo_predict)
    label_annotator = sv.LabelAnnotator(text_color=sv.Color.BLACK)
    bounding_box_annotator = sv.BoundingBoxAnnotator()
    annotated_image = cv2.imread(source)
    annotated_image = bounding_box_annotator.annotate(scene=annotated_image, detections=detections)
    annotated_image = label_annotator.annotate(scene=annotated_image, detections=detections)
    cv2.imwrite(result_name, annotated_image)


if __name__ == '__main__':
    process_video('car.mp4')