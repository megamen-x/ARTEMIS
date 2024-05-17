### Папка ```artemis-gradio```

Данная папка содержит frontend приложение на gradio.

<details>
  <summary> <strong><i>Описание содержимого каталога:</i></strong> </summary></ br>
  <br>
  
  1. **```app.py```** - файл для запуска приложение на Gradio;
  2. **```dataset```** - папка тестовых данных;

</details>



<details>
  <summary> <strong><i>Тестирование моделей с приложением на Gradio:</i></strong> </summary>
  
  - В Visual Studio Code (**Windows-PowerShell recommended**) через терминал последовательно выполнить следующие команды:

    - Клонирование репозитория:
    ```
    git clone https://github.com/megamen-x/ARTEMIS.git
    ```
    - Создание и активация виртуального окружения:
    ```
    cd ./ARTEMIS
    python -m venv .venv
    .venv\Scripts\activate
    ```
    - Уставновка зависимостей (CUDA 12.1 required):
    ```
    pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
    pip3 install -r requirements.txt
    ```
    - После установки зависимостей (3-5 минут) можно запустить Gradio:
    ```
    python ./artemis-gradio/app.py
    ```
    - или 
    ```
    cd ./artemis-gradio
    gradio app.py
    ```

</details> 
