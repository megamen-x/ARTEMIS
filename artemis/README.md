### Папка ```artemis```

Данная папка содержит frontend приложение на Flutter.

<details>
  <summary> <strong><i>Описание содержимого каталога:</i></strong> </summary></ br>
  
  - **Платформа**: 
  
  1. **```android```** - папка файлов конфигурации сборки под  Android (масштабируемость);
  2. **```linux```** - папка файлов конфигурации сборки под  Linux;
  3. **```web```** - папка файлов конфигурации сборки под  FlutterWeb (масштабируемость);
  4. **```windows```** - папка файлов конфигурации сборки под  Linux;

  - **Компоненты приложения**:

  5. **```assets```** - папка файлов ассетов приложения (фотографии, шрифты);
  6. **```lib```** - папка хранения dart-файлов страниц приложения;

  - **Приложение**:

  7. **```Release```** - папка хранения релиз-версии приложения;

  - **Файлы конфигурации**:

  8. **```analysis_options.yaml```** - файл конфигурации правил и исключений Flutter (в проекте не используется);
  9. **```pubspec.yaml```** - файл конфигурации зависимостей и библиотек Flutter;

</details>

<details>
  <summary> <strong><i>Запуск Flutter приложения на устройстве с Windows или Linux:</i></strong> </summary>
  
  - Перейдите в директорию **```Release```** на вашем устройстве и запустите приложение.

  - Или введите в терминал команду ниже (для Windows):
  
  ```
  cd ./ARTEMIS/artemis-app/Release/artemis.exe
  ```

</details> 

<details>
  <summary> <strong><i>Работа с Flutter приложением в debug режиме:</i></strong> </summary>
  
  - Если у вас установлен Flutter (и его SDK):
    
    - Запустить ```./artemis/lib/main.dart``` в режиме ```Run and Debug```

  - Иначе:

    - Установить Flutter SDK;
  
    - Склонировать репозиторий Flutter себе на компьютер;
  
    ```
    $ git clone -b beta https://github.com/flutter/flutter.git
    ```
    - В конец файла ```~/.bashrc``` добавить 
    ```
    export PATH=<путь к каталогу>/flutter/bin:$PATH
    export ANDROID_HOME=/<путь к каталогу>/android-sdk-linux
    export PATH=${PATH}:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
    ```
    - и проверить правильность установки с помощью
    ```
    $ flutter doctor
    ```
    - Запустить ```./artemis/lib/main.dart``` в режиме ```Run and Debug```
</details> 
