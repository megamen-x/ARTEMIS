FROM python:3.10

RUN apt-get update && apt-get install ffmpeg libsm6 libxext6 -y

WORKDIR /code

COPY ./docker-requirements.txt .

RUN pip install -r docker-requirements.txt

COPY . .

EXPOSE 8000

WORKDIR /code/artemis

CMD ["python", "manage.py", "makemigrations"]

CMD ["python", "manage.py", "migrate"]