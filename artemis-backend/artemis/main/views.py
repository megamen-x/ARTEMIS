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


from .serializers import ImageSerializer
from .models import UploadImageTest

from django.core.files.storage import FileSystemStorage
from django.contrib.auth import update_session_auth_hash
from .serializers import ChangePasswordSerializer
from django.core.cache import cache

from ultralytics import YOLO, RTDETR
sys.path.append('../ml')
from ml.cv2_converter import draw_boxes_from_list
from ml.ensemble import ensemble_boxes, count_classes

yolo_cache_key = 'model_cache'
yolo = cache.get(yolo_cache_key)

if yolo is None:
    yolo = YOLO(os.path.join('ml', 'best.pt'))
    cache.set(yolo_cache_key, yolo, None)

models = [yolo, ]

def clear_dirs(path_to_directory):
    for i in os.listdir(path_to_directory):
        shutil.rmtree(path_to_directory + i)

class ListUploadedFiles(generics.ListAPIView):
    queryset = UploadImageTest.objects.all()
    serializer_class = ImageSerializer

    def get_queryset(self, *args, **kwargs):
        return super().get_queryset(*args, **kwargs).filter(
            user=self.request.user
        )

class ImageViewSet(generics.ListAPIView):
    queryset = UploadImageTest.objects.all()
    serializer_class = ImageSerializer
    permission_classes = (IsAuthenticated, )

    def post(self, request, *args, **kwargs):
        # print(request.FILES['files'])
        # return HttpResponse(status=204)

        # file = request.FILES['files']

        if 'media' not in os.listdir('.'):
            os.mkdir('media/')

        json_ans = {"data": []}

        for file in request.FILES.getlist('files'):
            print(file.name)
            FileSystemStorage(location='media/images/').save(file.name, file)
            image = UploadImageTest.objects.create(image=file, user=request.user)

            boxes, _, labels = ensemble_boxes(
                models=models,
                path_to_image=('media/' + str(image.image)),
                # weights=weights
            )

            count_labels = count_classes(labels)

            bbox_image = draw_boxes_from_list(
                image_path1=('media/' + str(image.image)),
                boxes_1=boxes,
                labels1=labels
            )
            imwrite('media/' + str(image.image), bbox_image)
            count_deer = count_labels['1']
            # count_short, count_long, _ = count_labels['4'], count_labels['1'], count_labels['2']


            if 'archives' not in os.listdir('media'):
                os.makedirs('media/archives')
            if 'jsons' not in os.listdir('media'):
                os.makedirs('media/jsons')

                # нужно убрать изменение имен файлов - в ответе пользователю должно идти оригинальное название
                # deer_7.jpg сейчас конфертируется в deer_7_FneGAFh.jpg

            json_ans['data'].append(
                 {'column1': str(file.name), 'column2': str(count_deer),'column3': ['Deer']})

            with ZipFile('media/archives/file.zip', 'a') as cur_zipfile:
                cur_zipfile.write('media/' + str(image.image), str(file.name))

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
