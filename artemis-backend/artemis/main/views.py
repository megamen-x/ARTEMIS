import json
import os
import shutil
import sys
from pathlib import Path
from zipfile import ZipFile
from rest_framework.views import APIView
from rest_framework import generics, viewsets
from django.http import HttpResponse
from rest_framework.permissions import IsAuthenticatedOrReadOnly, IsAdminUser, IsAuthenticated
from cv2 import imwrite, imread
from rest_framework.response import Response
from django.contrib.auth.models import User
from rest_framework import status
from rest_framework import generics
import pandas as pd
import plotly
from torchvision.io import read_image
from torchvision.utils import save_image
import plotly.express as px
import kaleido
import cv2

from .serializers import ImageSerializer
from .models import UploadImageTest, UploadFile

from django.core.files.storage import FileSystemStorage
from django.contrib.auth import update_session_auth_hash
from .serializers import ChangePasswordSerializer, FileSerializer
from django.core.cache import cache

from ultralytics import YOLO, RTDETR
sys.path.append('../ml')
from ml.cv2_converter import draw_boxes_from_list
from ml.ensemble import ensemble_boxes, count_classes, count_classes_model
from ml.main import load_model, detections, label2id

deer_names = {
    'Deer': 'Олень - Cervus',
    'Musk Deer': 'Кабарга - Moschus',
    'Roe Deer': 'Косуля - Capreolus',
}


detector_cache_key = 'detector_cache'
detector = cache.get(detector_cache_key)

model_cache_key = 'model_cache'
model = cache.get(model_cache_key)

if detector is None:
    detector = YOLO(os.path.join('ml', 'best.pt'))
    cache.set(detector_cache_key, detector, None)

if model is None:
    model = load_model(num_classes=3, path_to_model=os.path.join('ml', 'model_epoch_11.pt'), pretrained=False)
    cache.set(model_cache_key, model, None)

models = [detector, ]

def clear_dirs(path_to_directory, save_image=True):
    for i in os.listdir(path_to_directory):
        if i not in ['labels', 'images']:
            shutil.rmtree(path_to_directory + i)

def create_dirs(path_to_directory):
    p = Path(path_to_directory)
    if 'archives' not in os.listdir(p):
        os.makedirs(p / 'archives')
    if 'jsons' not in os.listdir(p):
        os.makedirs(p / 'jsons')
    if 'zips' not in os.listdir(p):
        os.makedirs(p / 'zips')
    if 'plots' not in os.listdir(p):
        os.makedirs(p / 'plots')
    if 'labels' not in os.listdir(p):
        os.makedirs(p / 'labels')

class ListUploadedFiles(generics.ListAPIView):
    queryset = UploadImageTest.objects.all()
    serializer_class = ImageSerializer
    permission_classes = (IsAuthenticated,)

    def get_queryset(self, *args, **kwargs):
        return super().get_queryset(*args, **kwargs).filter(
            user=self.request.user
        )


class ZipViewSet(generics.ListAPIView):
    queryset = UploadFile.objects.all()
    serializer_class = FileSerializer
    permission_classes = (IsAuthenticated, )

    def post(self, request, *args, **kwargs):
        # print(request.FILES['files'])
        # return HttpResponse(status=204)

        file = request.data.get('file')
        if file is None:
            file = request.FILES.get('files')

        if 'media' not in os.listdir('.'):
            os.mkdir('media/')

        create_dirs('media/')

        json_ans = {"data": []}
        count_label_model = {'Musk Deer': 0,
                             'Deer': 0,
                             'Roe Deer': 0}

        FileSystemStorage(location='media/zips/').save(file.name, file)

        with ZipFile('media/zips/' + file.name) as zf:
            for name in zf.namelist():
                zf.extract(name, 'media/images/')
                if Path('media/images/' + name).suffix.lower() in ['.jpg', '.jpeg', '.png']:
                    # image = UploadFile.objects.create(file=file.name, user=request.user)

                    boxes, _, labels = ensemble_boxes(
                        models=models,
                        path_to_image=('media/images/' + name),
                        # weights=weights
                    )

                    if len(labels) != 0:
                        count_label_detector = count_classes(labels)
                    else:
                        count_label_detector = {'1': 0, '2': 0, '3': 0}

                    bbox_image = draw_boxes_from_list(
                        image_path1=('media/images/' + name),
                        boxes_1=boxes,
                        labels1=labels
                    )
                    imwrite('media/images/' + name, bbox_image)

                    pred = detections(boxes, model, 'media/images/' + name)

                    if pred:
                        if isinstance(pred, str):
                            pred = [pred, ]
                        yolo_label = [f"{label2id[pred[0]]} {box[0]} {box[1]} {box[2]} {box[3]}\n" for box in boxes]
                        count_label_model = count_classes_model(count_label_model, pred)
                        type = 'a' if not os.path.exists('media/labels/' + Path(str(file.name)).stem + '.txt') else 'w'
                        with open('media/labels/' + Path(name).stem + '.txt', type) as f:
                            print(''.join(yolo_label), file=f)
                    else:
                        pred = []

                    json_ans['data'].append(
                         {'column1': name, 'column2': str(count_label_detector['1']),
                          'column3': [deer_names[p] for p in pred]})

                    with ZipFile('media/archives/file.zip', 'a') as cur_zipfile:
                        cur_zipfile.write('media/images/' + name, name)



            df = pd.DataFrame({'class': ['Кабарга', 'Олень', 'Косуля'],
                               'count': count_label_model.values()})

            fig = px.bar(df, x="class", y="count",
                         color='class',
                         color_discrete_map={"Косуля": "rgb(68, 96, 88)",
                                             "Олень": "rgb(2, 176, 125)",
                                             'Кабарга': 'rgb(9, 86, 81)'},
                         template='plotly_dark',
                         text_auto=True
                         )
            fig.update_layout(
                plot_bgcolor='rgb(21, 21, 21)',
                paper_bgcolor='rgb(21, 21, 21)',
                width=500,
                height=500,
                showlegend=False
            )
            fig.update_traces(textposition='outside')
            fig.update_yaxes(title='Суммарное количество на фотографиях')
            fig.update_xaxes(title='Вид оленя', )

            fig.write_image("media/plots/deers_fig.jpeg", format='jpeg', engine='kaleido')

            with open('media/jsons/data.txt', 'w') as outfile:
                 json.dump(json_ans, outfile)

            with ZipFile('media/archives/file.zip', 'a') as cur_zipfile:
                cur_zipfile.write('media/jsons/data.txt', 'data.txt')
                cur_zipfile.write("media/plots/deers_fig.jpeg", "deers_fig.jpeg")

        with open('media/archives/file.zip', 'rb') as cur_zipfile:
            response = HttpResponse(cur_zipfile, content_type='application/zip')
            response['Content-Disposition'] = f'attachment; filename=cur_zip_file.zip'

        clear_dirs('media/')
        return response


class FilesViewSet(generics.ListAPIView):
    queryset = UploadFile.objects.all()
    serializer_class = FileSerializer
    permission_classes = (IsAuthenticated, )

    def post(self, request, *args, **kwargs):
        # print(request.FILES['files'])
        # return HttpResponse(status=204)

        # file = request.FILES['files']

        data = request.data.getlist('file')
        if len(data) == 0:
            data = request.FILES.getlist('files')

        if 'media' not in os.listdir('.'):
            os.mkdir('media/')

        create_dirs('media/')

        json_ans = {"data": []}
        count_label_model = {'Musk Deer': 0,
                             'Deer': 0,
                             'Roe Deer': 0,}

        for file in data:
            FileSystemStorage(location='media/images/').save(file.name, file)
            # image
            if Path('media/images/' + file.name).suffix.lower() in ['.jpg', '.jpeg', '.png']:
                image = UploadFile.objects.create(file=file.name, user=request.user)
                boxes, _, labels = ensemble_boxes(
                    models=models,
                    path_to_image=('media/images/' + str(image.file)),
                    # weights=weights
                )

                if len(labels) != 0:
                    count_label_detector = count_classes(labels)
                else:
                    count_label_detector = {'1': 0, '2': 0, '3': 0}

                bbox_image = draw_boxes_from_list(
                    image_path1=('media/images/' + str(image.file)),
                    boxes_1=boxes,
                    labels1=labels
                )
                imwrite('media/images/' + str(image.file), bbox_image)
                pred = detections(boxes, model, 'media/images/' + str(image.file))

                if pred:
                    if isinstance(pred, str):
                        pred = [pred, ]
                    count_label_model = count_classes_model(count_label_model, pred)
                    yolo_label = [f"{label2id[pred[0]]} {box[0]} {box[1]} {box[2]} {box[3]}\n" for box in boxes]
                    type = 'a' if not os.path.exists('media/labels/' + Path(str(file.name)).stem + '.txt') else 'w'
                    with open('media/labels/' + Path(str(file.name)).stem + '.txt', type) as f:
                        print(''.join(yolo_label), file=f)
                else:
                    pred = []
                json_ans['data'].append(
                    {'column1': str(file.name), 'column2': str(count_label_detector['1']),
                     'column3': [deer_names[p] for p in pred]})

                with ZipFile('media/archives/file.zip', 'a') as cur_zipfile:
                    cur_zipfile.write('media/images/' + str(image.file), str(file.name))

            df = pd.DataFrame({'class': ['Косуля', 'Олень', 'Кабарга'],
                               'count': list(count_label_model.values())})

            fig = px.bar(df, x="class", y="count",
                         color='class',
                         color_discrete_map={"Косуля": "rgb(68, 96, 88)",
                                             "Олень": "rgb(2, 176, 125)",
                                             'Кабарга': 'rgb(9, 86, 81)'},
                         template='plotly_dark',
                         text_auto=True
                         )
            fig.update_layout(
                plot_bgcolor='rgb(21, 21, 21)',
                paper_bgcolor='rgb(21, 21, 21)',
                width=500,
                height=500,
                showlegend=False
            )
            fig.update_traces(textposition='outside')
            fig.update_yaxes(title='Суммарное количество на фотографиях')
            fig.update_xaxes(title='Вид оленя', )

            fig.write_image("media/plots/deers_fig.jpeg", format='jpeg', engine='kaleido')

            with open('media/jsons/data.txt', 'w') as outfile:
                 json.dump(json_ans, outfile)

        if len(json_ans['data']) == 0:
            with open('media/jsons/data.txt', 'w') as outfile:
                 json.dump(json_ans, outfile)

        with ZipFile('media/archives/file.zip', 'a') as cur_zipfile:
            cur_zipfile.write('media/jsons/data.txt', 'data.txt')
            cur_zipfile.write("media/plots/deers_fig.jpeg", "deers_fig.jpeg")

        with open('media/archives/file.zip', 'rb') as cur_zipfile:
            response = HttpResponse(cur_zipfile, content_type='application/zip')
            response['Content-Disposition'] = f'attachment; filename=cur_zip_file.zip'

        clear_dirs('media/')
        return response

class ActiveLearningViewSet(generics.ListAPIView):
    queryset = UploadFile.objects.all()
    serializer_class = FileSerializer
    permission_classes = (IsAuthenticated, )

    def post(self, request, *args, **kwargs):

        if 'wrong_detections' not in os.listdir('.'):
            os.mkdir('wrong_detections/')

        latid2label = {
            'Олень - Cervus': '0',
            'Кабарга - Moschus': '1',
            'Косуля - Capreolus': '2',
        }

        file = request.data.get('file')
        if file is None:
            file = request.FILES.get('files')

        if 'wrong_detections' not in os.listdir('.'):
            os.mkdir('wrong_detections/')
        for dir in ['Deer', 'Musk Deer', 'Roe Deer']:
            if dir not in os.listdir('wrong_detections/'):
                os.makedirs('wrong_detections/' + dir)

        if Path(file.name).suffix.lower() == '.json':
            FileSystemStorage(location='media/jsons/').save(file.name, file)
            UploadFile.objects.create(file=file.name, user=request.user)

            with open('media/jsons/' + file.name) as f:
                data = json.load(f)
                data = data.get('data')

            if data is None:
                return HttpResponse(status=400)

            for d in data:
                file_name = d['column1']
                id = latid2label[d['column3'][0]]
                label_name = Path(d['column1']).stem + '.txt'
                image = imread('media/images/' + file_name)
                height, width, _ = image.shape

                with open('media/labels/' + label_name, 'r') as f:
                    _, x_min, y_min, x_max, y_max = f.read().replace('\n', '').split()

                    x_min = int(float(x_min) * width)
                    y_min = int(float(y_min) * height)
                    x_max = int(float(x_max) * width)
                    y_max = int(float(y_max) * height)

                    w = x_max - x_min
                    h = y_max - y_min

                    crop = image[y_min + 3:y_min + h - 3,
                           x_min + 3:x_min + w - 3]

                file_path = ''
                if id == '0':
                    file_path = 'wrong_detections/Deer/'
                elif id == '1':
                    file_path = 'wrong_detections/Musk Deer/'
                elif id == '2':
                    file_path = 'wrong_detections/Roe Deer/'
                cv2.imwrite(file_path + file_name, crop)

        return HttpResponse(status=200)


class UpdatePassword(APIView):
    permission_classes = (IsAuthenticated, )

    def put(self, request, *args, **kwargs):
        self.object = self.request.user
        serializer = ChangePasswordSerializer(data=request.data)

        if serializer.is_valid():
            # Check old password
            old_password = serializer.data.get("old_password")
            if not self.object.check_password(old_password):
                return Response({"old_password": ["Wrong password."]},
                                status=status.HTTP_400_BAD_REQUEST)
            # set_password also hashes the password that the user will get
            self.object.set_password(serializer.data.get("new_password"))
            self.object.save()
            return Response(status=status.HTTP_204_NO_CONTENT)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
