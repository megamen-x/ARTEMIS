"""drfsite URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/3.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include, re_path
from main.views import FilesViewSet, UpdatePassword, ListUploadedFiles, ZipViewSet, ActiveLearningViewSet
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView, TokenVerifyView

urlpatterns = [
    path('admin/', admin.site.urls),
    # path('sign/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('auth/', include('djoser.urls')),
    re_path('^auth/', include('djoser.urls.authtoken')),
    path('files/', FilesViewSet.as_view(), name='upload'),
    path('zip/', ZipViewSet.as_view(), name='upload'),
    path('change/', UpdatePassword.as_view(), name='change'),
    path('list_files/', ListUploadedFiles.as_view(), name='list_files'),
    path('active_learning/', ActiveLearningViewSet.as_view(), name='upload'),
]
