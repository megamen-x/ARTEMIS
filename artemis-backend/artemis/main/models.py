from django.contrib.auth.models import User
from django.db import models

def upload_to(instance, filename):
    return '/'.join(['images', filename])

class UploadImageTest(models.Model):
    image = models.ImageField(upload_to=upload_to, blank=True, null=True)
    user = models.ForeignKey(User, verbose_name='Пользователь', on_delete=models.CASCADE)

class UploadFile(models.Model):
    file = models.FileField(upload_to=upload_to, blank=True, null=True)
    user = models.ForeignKey(User, verbose_name='Пользователь', on_delete=models.CASCADE)
