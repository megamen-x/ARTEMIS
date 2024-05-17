import gradio as gr
import webbrowser, os
import time
from processing import *

text = 'Здесь будут общие данные'

filepath="./"

theme = gr.themes.Soft(
    primary_hue="green",
    secondary_hue="lime",
    text_size="lg",
    spacing_size="lg",
    font=[gr.themes.GoogleFont('Inter'), gr.themes.GoogleFont('Limelight'), 'system-ui', 'sans-serif'],
    # Montserrat 
).set(
    block_radius='*radius_xxl',
    button_large_radius='*radius_xl',
    button_large_text_size='*text_md',
    button_small_radius='*radius_xl',
)

def warning_file():
    gr.Warning("Выберите файл для распознавания!")

def info_fn():
    gr.Info("Необходимо загрузить ваш файл")

def info_req():
    gr.Info("Параметры заданы по умолчанию")
    
def info_res():
    gr.Info("Полный JSON-файл можно найти в папке проекта")

def photoProcessing(file, ):
    time.sleep(1)
    print('so file is ', file)
    if file != None:
        info_req()
        process_image(file, 'result.jpg')
        info_res()
        string = 'ну, это олень'
        return 'result.jpg', string
    else:
        warning_file()
    

def videoProcessing(file, ):
    time.sleep(1)
    if file != None:
        info_req()
        process_video(source=file, result_name='result.mp4')
        info_res()
        with open('detections.csv', mode='r') as detect_file:
            string = detect_file.readlines()
        full_text = ''
        for el in string:
            el = el.replace('\n', '')
            data = el.split(',')
            full_text += 'Начало интервала: ' + data[0] + '; Конец интервала: ' + data[1] + '; Количество встреченных лосей (автомобилей): ' + data[2] + '\n'
        return 'result.mp4', full_text
    else:
        warning_file()


def fileOpen():
    webbrowser.open(os.path.realpath(filepath))
   
output = [gr.Dataframe(row_count = (4, "dynamic"), col_count=(4, "fixed"), label="Predictions")]

with gr.Blocks(theme=theme) as demo:
    gr.Markdown('<a name="readme-top"></a>\
        <p align="center" ><font size="30px"><strong style="font-family: Limelight">ARTEMIS</strong></font></p> \
        <p align="center"><font size="5px">Автоматизированный инструмент классификации парнокопытных на примере трех видов рода "олени" <br>\
            Создано <strong>megamen</strong>, совместно с <strong>Министерством природных ресурсов и экологии РФ</strong> </font></p> ')

    with gr.Row():
        with gr.Column():
            with gr.Tab('Обработка фотографий'):
                file_photo = gr.File(label="Фотография", file_types=['.png','.jpeg','.jpg'])
                with gr.Column():
                    with gr.Row(): 
                        btn_photo = gr.Button(value="Начать распознавание",)
                        trigger_info = gr.Button(value="Подробнее",)
                with gr.Row():
                    with gr.Tab('Результат обработки'):
                        with gr.Row():
                            predictImage = gr.Image(type="pil", label="Обработанная фотография")
                            predictImageClass = gr.Textbox(label="Результат обработки", placeholder="Здесь будут общие данные по файлу", interactive=False, lines=7)
            
            with gr.Tab('Обработка видео'):
                file_video = gr.File(label="Видео", file_types=['.mp4','.mkv'])
                with gr.Column():
                    with gr.Row(): 
                        btn_video = gr.Button(value="Начать распознавание",)
                        trigger_info = gr.Button(value="Подробнее",)
                with gr.Row():
                    with gr.Tab('Результат обработки'):
                        with gr.Row():
                            predictVideo = gr.Video(label="Обработанное видео", interactive=False)
                            predictVideoClass = gr.Textbox(label="Результат обработки", placeholder="Здесь будут общие данные по файлу", interactive=False, lines=7)

    with gr.Row(): 
        with gr.Row(): 
            btn2 = gr.Button(value="Посмотреть json",)
            clr_btn = gr.ClearButton([file_photo, file_video, predictImage, predictVideo, predictImageClass, predictVideoClass ], value="Очистить контекст",)

    btn_photo.click(photoProcessing, inputs=[file_photo, ], outputs=[predictImage, predictImageClass,])
    btn_video.click(videoProcessing, inputs=[file_video, ], outputs=[predictVideo, predictVideoClass,])
    btn2.click(fileOpen)
    trigger_info.click(info_fn, None)

demo.launch(allowed_paths=["/assets/"])


    