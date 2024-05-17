### Папка ```artemis-server```

Данная папка содержит Django REST API Server.

<details>
  <summary> <strong><i>Описание содержимого каталога:</i></strong> </summary></ br>

  - **Сервер**:

  1. **```artemis```** - папка с конфигурационнымм данными Django Rest Framework; \
     1.1 **```settings.py```** - файл с настройками проекта \
     1.2 **```urls.py```** - файл со всеми url-ссылками
  2. **```main```** - папка с основным функционалом \
     2.1 **```models.py```** - файл с описанием моделей (нужны для работы с БД посредством Django ORM) \
     2.2 **```serializers.py```** - файл с описанием сериализаторов \
     2.3 **```views.py```** - файл с описанием представлений (они отвечают за работу приложения на Django Rest Framework)

  - **Окружение**:

  3. **```requirements.txt```** - файл зависимостей для подготовки корректного окружения запуска решения;
</details>


<details>
  <summary> <strong><i>Запуск Django Rest Framework-сервера:</i></strong> </summary>
  
  - В Visual Studio Code (**Windows-PowerShell recommended**) через терминал последовательно выполнить следующие команды:
  
    - Клонирование репозитория:
    ```
    git clone https://github.com/megamen-x/ARTEMIS.git
    ```
    - Создание и активация виртуального окружения (Протестировано на **Python 3.10.10**):
    ```
    cd ./ARTEMIS
    python -m venv .venv
    .venv\Scripts\activate
    ```
    - Уставновка зависимостей (при использовании **CUDA 12.1**):
    ```
    pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
    pip3 install -r requirements.txt
    ```
    - Уставновка зависимостей (при использовании **CPU**):
    ```
    pip3 install torch torchvision torchaudio
    pip3 install -r requirements.txt
    ```
    - После установки зависимостей (5-7 минут):
    ```
    cd artemis-backend/artemis
    python manage.py makemigrations
    python manage.py migrate
    python manage.py runserver
    ```
    - В случае, если не работает стандратная команда makemigrations:
    ```
    python manage.py makemigrations main
    ```
</details> 
