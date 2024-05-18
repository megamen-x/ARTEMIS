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
from cv2 import imwrite
from rest_framework.response import Response
from django.contrib.auth.models import User
from rest_framework import status
from rest_framework import generics
import pandas as pd
import plotly
import plotly.express as px
import kaleido

from .serializers import ImageSerializer
from .models import UploadImageTest, UploadFile

from django.core.files.storage import FileSystemStorage
from django.contrib.auth import update_session_auth_hash
from .serializers import ChangePasswordSerializer, FileSerializer
from django.core.cache import cache

from ultralytics import YOLO, RTDETR
sys.path.append('../ml')
from ml.cv2_converter import draw_boxes_from_list
from ml.ensemble import ensemble_boxes, count_classes
from ml.main import load_model, detections

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

def clear_dirs(path_to_directory):
    for i in os.listdir(path_to_directory):
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

        # file = request.FILES['files']

        if 'media' not in os.listdir('.'):
            os.mkdir('media/')

        create_dirs('media/')

        json_ans = {"data": []}

        file = request.FILES.get('files')
        FileSystemStorage(location='media/zips/').save(file.name, file)

        with ZipFile('media/zips/' + file.name) as zf:
            for name in zf.namelist():
                zf.extract(name, 'media/images/')
                if Path('media/images/' + name).suffix in ['.jpg', '.jpeg', '.png']:
                    # image = UploadFile.objects.create(file=file.name, user=request.user)

                    boxes, _, labels = ensemble_boxes(
                        models=models,
                        path_to_image=('media/images/' + name),
                        # weights=weights
                    )

                    count_labels = count_classes(labels)

                    bbox_image = draw_boxes_from_list(
                        image_path1=('media/images/' + name),
                        boxes_1=boxes,
                        labels1=labels
                    )
                    imwrite('media/images/' + name, bbox_image)
                    count_deer = count_labels['1']

                    pred = detections(detector, model, 'media/images/' + name)
                    # print(pred)

                    json_ans['data'].append(
                         {'column1': name, 'column2': str(count_deer),'column3': [pred]})

                    with ZipFile('media/archives/file.zip', 'a') as cur_zipfile:
                        cur_zipfile.write('media/images/' + name, name)
                # video
                elif Path('media/images/' + file.name).suffix in ['.mp4', '.mkv', '.mov', '.MOV']:
                    json_ans['data'].append(
                        {'column1': str(file.name), 'column2': str(2), 'column3': ['Deer']})

            df = pd.DataFrame({'class': ['Косуля', 'Олень', 'Кабарга'], 'count': [313, 1284, 6]})

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

        if 'media' not in os.listdir('.'):
            os.mkdir('media/')

        if 'archives' not in os.listdir('media'):
            os.makedirs('media/archives')
        if 'jsons' not in os.listdir('media'):
            os.makedirs('media/jsons')

        json_ans = {"data": []}

        for file in request.FILES.getlist('files'):
            FileSystemStorage(location='media/images/').save(file.name, file)
            # image
            if Path('media/images/' + file.name).suffix in ['.jpg', '.jpeg', '.png', '.JPG']:
                image = UploadFile.objects.create(file=file.name, user=request.user)
                print(image.file)
                boxes, _, labels = ensemble_boxes(
                    models=models,
                    path_to_image=('media/images/' + str(image.file)),
                    # weights=weights
                )

                count_labels = count_classes(labels)

                bbox_image = draw_boxes_from_list(
                    image_path1=('media/images/' + str(image.file)),
                    boxes_1=boxes,
                    labels1=labels
                )
                imwrite('media/images/' + str(image.file), bbox_image)
                count_deer = count_labels['1']
                # count_short, count_long, _ = count_labels['4'], count_labels['1'], count_labels['2']

                pred = detections(detector, model, 'media/images/' + str(image.file))
                print(pred)

                json_ans['data'].append(
                     {'column1': str(file.name), 'column2': str(count_deer),'column3': [pred]})

                with ZipFile('media/archives/file.zip', 'a') as cur_zipfile:
                    cur_zipfile.write('media/images/' + str(image.file), str(file.name))
            # video
            elif Path('media/images/' + file.name).suffix in ['.mp4', '.mkv', '.mov', '.MOV']:
                video = UploadFile.objects.create(file='media/images/' + file.name, user=request.user)
                print(video)
                json_ans['data'].append(
                    {'column1': str(file.name), 'column2': str(2), 'column3': ['Deer']})

            with open('media/jsons/data.txt', 'w') as outfile:
                 json.dump(json_ans, outfile)

        with ZipFile('media/archives/file.zip', 'a') as cur_zipfile:
            cur_zipfile.write('media/jsons/data.txt', 'data.txt')

        with open('media/archives/file.zip', 'rb') as cur_zipfile:
            response = HttpResponse(cur_zipfile, content_type='application/zip')
            response['Content-Disposition'] = f'attachment; filename=cur_zip_file.zip'

        clear_dirs('media/')
        return response


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
