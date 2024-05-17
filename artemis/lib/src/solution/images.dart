// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace, unused_import, no_logic_in_create_state, prefer_typing_uninitialized_variables

import 'dart:io';
import 'dart:convert';

import 'package:mime/mime.dart';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http_parser/http_parser.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

// import 'package:artemis/lib/main.dart';
import '../../main.dart';
import '../main/team.dart';
import '../system/account.dart';
import 'images_ext.dart';
import 'videos.dart';

List <String> files = [];


class ImagesWidget extends StatefulWidget {
  final filesarr, images, dataEmptyFlag, prevpage, userData;
  ImagesWidget({super.key, @required this.filesarr, this.images, this.dataEmptyFlag, this.prevpage, this.userData});

  @override
  State<ImagesWidget> createState() => ImagesState(filesarr: filesarr, images: images, dataEmptyFlag: dataEmptyFlag, prevpage: prevpage, userData: userData);
}

class ImagesState extends State<ImagesWidget> {

  var filesarr, images, dataEmptyFlag, prevpage, userData;
  ImagesState({ @required this.filesarr, this.images, this.dataEmptyFlag, this.prevpage, this.userData});

  bool loadingFlag = false;
  bool dataClearFlag = false;

  var shortcall = ShortenFileName();
  String current = Directory.current.path;
  late Uri fileprovider = Uri.parse('file:///$current');

  List<String> newfileargs = [];
  List<DataModel> dataList = [DataModel(column1: ' ', column2: ' ', column3: [' ',])];
  
  @override
  void initState() {
    super.initState();
    dataList = filesarr;
  }

  Future<void> uploadImage(context) async {
    setState(() {
      loadingFlag = true;
    });

    final picker = ImagePicker();
    List<XFile>? imageFileList = [];
    List<String>? pathFiles = [];

    final List<XFile> selectedImages = await picker.pickMultiImage();
    if (selectedImages.isNotEmpty) {
        imageFileList.addAll(selectedImages);
    }
    for (var i = 0; i < imageFileList.length; i++) {
      if (Platform.isWindows) {
        pathFiles.add(imageFileList[i].path.replaceAll('\\', '/'));
      }
      if (Platform.isLinux) {
        pathFiles.add(imageFileList[i].path);
      }
    }
    try {    
      var  postUri = Uri.parse('http://127.0.0.1:8000/photo/');
      var request = http.MultipartRequest('POST', postUri);

      for (var i = 0; i < pathFiles.length; i++) {
        String? mediaType = lookupMimeType(pathFiles[i].split("/").last);
        request.files.add(
          await http.MultipartFile.fromPath(
            'files', 
            pathFiles[i], 
            filename: pathFiles[i].split("/").last, 
            contentType: mediaType != null ? MediaType.parse(mediaType) : null,
          ),
        );
      }
      Map<String, String> userDataString = {
        "Authorization": "Token ${userData['auth_token']}"
      };

      request.headers.addAll(userDataString);
      var streamedResponse  = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        unzipFileFromResponse(response.bodyBytes);
        String path = '';
        if (Platform.isWindows || Platform.isLinux) {
          path = "./responce/data.txt";
        }
        File dataFile = File(path);
        String dataString = dataFile.readAsStringSync();
        final responceMap = jsonDecode(dataString);
        final dataMap = jsonDecode(jsonEncode(responceMap["data"]));
        
        setState(() {
          dataClearFlag = true;
          dataEmptyFlag = false;
          loadingFlag = false;
          dataList = [];
        });

        setState(() {
          var tmp = dataMap.length;
          for (var i = 0; i < tmp; i++) {
            DataModel newData = DataModel.fromJson(dataMap[i]);
            dataList.add(newData);
          }
          String resp = '\\responce';
          current = current + resp;
        });
      }
      else {
        setState(() {
          loadingFlag = false;
        });
      }
    } on SocketException {
      setState(() {
        Sample.AlshowDialog(context, 'Нет соединения с сервером!', 'Проверьте состояние сервера и попробуйте снова');
        loadingFlag = false;
      });
    } on HttpException {
      setState(() {
        Sample.AlshowDialog(context, "Не удалось найти метод post!", 'Проверьте состояние сервера и попробуйте снова');
        loadingFlag = false;
      });
    } on FormatException {
      setState(() {
        Sample.AlshowDialog(context, "Неправильный формат ответа!", 'Проверьте состояние сервера и попробуйте снова');
        loadingFlag = false;
      });
    }
  }

  Future<void> _fileProvider() async {
    if (!await launchUrl(fileprovider)) {
      throw Exception('Could not launch $fileprovider');
    }
  }

  Future<void> clearData() async {
    if (Platform.isWindows || Platform.isLinux) {
      // images = [
      //   "./assets/images/loader.png",
      // ];
      dataList = [DataModel(column1: ' ', column2: ' ', column3: [' ',])];
      deleteFilesInFolder("./responce");
    }
    setState(() {
      dataEmptyFlag = false;
    });
  }

  // delete files in folder func
  Future<void> deleteFilesInFolder(String folderPath) async {
    final directory = Directory(folderPath);
    if (await directory.exists()) {
      await for (final entity in directory.list()) {
        if (entity is File) {
          await entity.delete();
        }
      }
    }
  }

  // unzip server responce
  Future<void> unzipFileFromResponse(List<int> responseBody) async {
    final archive = ZipDecoder().decodeBytes(responseBody);
    images = [];
    for (final file in archive) {
      final filename = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        if (filename.contains('.jpg') || filename.contains('.jpeg') || filename.contains('.png') || filename.contains('.bmp')) {
          if (Platform.isWindows || Platform.isLinux) {
            File('responce/$filename')
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
            images.add('responce/$filename');
          }
        }
        else {
          if (Platform.isWindows || Platform.isLinux) {
            File('responce/$filename')
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
          }
        }
      } else {
        await Directory('responce/$filename').create(recursive: true);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    double baseWidth = 1600;
    double frame = MediaQuery.of(context).size.width / baseWidth;
    double fframe = frame * 0.97;
    return Scaffold(
      body: WindowBorder(
        color: Colors.black,
        width: 1,
        child: 
        Container(
          decoration: BoxDecoration(
            color: Color(0xFF000000),
          ),
          child: Center(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFF1C4A3D),
                borderRadius: BorderRadius.circular(20.0*fframe),
              ),
              padding: EdgeInsets.fromLTRB(10*fframe, 20*fframe, 10*fframe, 30*fframe),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // window-btns
                  Container(
                    width: 1580*fframe,
                    height: 90*fframe,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // name
                            Container(
                              width: 345*fframe,
                              height: 90*fframe,
                              decoration: BoxDecoration(
                                color: Color(0xFFF9F8F6),
                                borderRadius: BorderRadius.circular(20.0*fframe),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('ARTEMIS', 
                                    textAlign: TextAlign.center, 
                                    style: TextStyle(
                                      color: Color(0xFF000000),
                                      fontFamily: 'Limelight',
                                      fontSize: 48*fframe,
                                      fontWeight: FontWeight.w400,
                                      height: 1.0*fframe/frame,
                                    )
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 40*fframe,
                            ),
                            // menu
                            Container(
                              width: 345*fframe,
                              height: 90*fframe,
                              padding: EdgeInsets.symmetric(vertical: 0*fframe, horizontal: 70*fframe),
                              decoration: BoxDecoration(
                                color: Color(0xFFF9F8F6),
                                borderRadius: BorderRadius.circular(20.0*fframe),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // back
                                  Container(
                                    width: 50*fframe,
                                    height: 50*fframe,
                                    decoration: BoxDecoration (
                                        color: Color(0xFF0A3725),
                                        borderRadius: BorderRadius.circular(10.0*fframe),
                                    ),
                                    child: OutlinedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (_, __, ___) =>  VideosWidget(filesarr: filesarr, dataEmptyFlag: dataEmptyFlag, prevpage: ImagesWidget(filesarr: filesarr, dataEmptyFlag: dataEmptyFlag, prevpage: prevpage, userData:userData), userData:userData),
                                            transitionsBuilder: (_, animation, __, child) {
                                              return FadeTransition(
                                                opacity: animation,
                                                child: child,
                                              );
                                            }
                                          )
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        padding: EdgeInsets.fromLTRB(0*frame, 0*frame, 0*frame, 0*frame),
                                        side: const BorderSide(color: Color(0xffF9F8F6), width: 0),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0*fframe)),
                                      ),
                                      child: SizedBox(
                                        width: 40*fframe,
                                        height: 40*fframe,
                                        child: Center(
                                          child: SvgPicture.asset(
                                            'assets/images/system/camera.svg',
                                            semanticsLabel: 'Camera'
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // team
                                  Container(
                                    width: 50*fframe,
                                    height: 50*fframe,
                                    decoration: BoxDecoration (
                                        color: Color(0xFF0A3725),
                                        borderRadius: BorderRadius.circular(10.0*fframe),
                                    ),
                                    child: OutlinedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (_, __, ___) =>  AccWidget(prevpage: ImagesWidget(filesarr: filesarr, dataEmptyFlag: dataEmptyFlag, prevpage: prevpage, userData:userData), userData:userData),
                                            transitionsBuilder: (_, animation, __, child) {
                                              return FadeTransition(
                                                opacity: animation,
                                                child: child,
                                              );
                                            }
                                          )
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        padding: EdgeInsets.fromLTRB(0*frame, 0*frame, 0*frame, 0*frame),
                                        side: const BorderSide(color: Color(0xffF9F8F6), width: 0),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0*fframe)),
                                      ),
                                      child: SizedBox(
                                        width: 45*fframe,
                                        height: 45*fframe,
                                        child: Center(
                                          child: SvgPicture.asset(
                                            'assets/images/system/account.svg',
                                            semanticsLabel: 'Camera'
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // camera
                                  Container(
                                    width: 50*fframe,
                                    height: 50*fframe,
                                    decoration: BoxDecoration (
                                        color: Color(0xFF0A3725),
                                        borderRadius: BorderRadius.circular(10.0*fframe),
                                    ),
                                    child: OutlinedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (_, __, ___) =>  TeamWidget(prevpage: ImagesWidget(filesarr: filesarr, dataEmptyFlag: dataEmptyFlag, prevpage: prevpage, userData:userData), userData:userData),
                                            transitionsBuilder: (_, animation, __, child) {
                                              return FadeTransition(
                                                opacity: animation,
                                                child: child,
                                              );
                                            }
                                          )
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        padding: EdgeInsets.fromLTRB(0*frame, 0*frame, 0*frame, 0*frame),
                                        side: const BorderSide(color: Color(0xffF9F8F6), width: 0),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0*fframe)),
                                      ),
                                      child: SizedBox(
                                        width: 45*fframe,
                                        height: 45*fframe,
                                        child: Center(
                                          child: SvgPicture.asset(
                                            'assets/images/system/team.svg',
                                            semanticsLabel: 'Camera'
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 200*fframe,
                          height: 60*fframe,
                          decoration: BoxDecoration(
                            color: Color(0xFF14342B),
                            borderRadius: BorderRadius.circular(20.0*fframe),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: const <Widget>[
                              WindowButtons(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // main-frame
                  Container(
                    width: 1580*fframe,
                    height: 750*fframe,
                    decoration: BoxDecoration(
                      color: Color(0xFF14342B),
                      borderRadius: BorderRadius.circular(30.0*fframe),
                    ),
                    padding: EdgeInsets.fromLTRB(20*fframe, 30*fframe, 20*fframe, 30*fframe),
                    child: 
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 1360*fframe,
                          padding: EdgeInsets.fromLTRB(0*fframe, 0*fframe, 0*fframe, 30*fframe),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              // btn add
                              Center(
                                child: 
                                ElevatedButton.icon(
                                  icon: loadingFlag
                                      ? const Center(child: SizedBox(width: 35, height: 35, child: CircularProgressIndicator(color: Color(0xFF000000) )))
                                      : const Icon(Icons.add_rounded, color: Color(0xFF000000), size: 35,),
                                  label: Text(
                                    loadingFlag ? 'ОБРАБОТКА...' : 'ВЫБРАТЬ ФОТО',
                                    style: TextStyle(
                                      fontFamily: 'Inter', 
                                      fontSize: 23*fframe,
                                      fontWeight: FontWeight.w700,
                                      height: 1.3*fframe/frame,
                                      color: Color(0xFF000000),
                                    ),
                                  ),
                                  onPressed: () => loadingFlag ? null : uploadImage(context),
                                  style: 
                                  ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                                    side: const BorderSide(color: Color(0xFFF9F8F6), width: 0),
                                    padding: const EdgeInsets.all(14),
                                    backgroundColor: Color(0xFFF9F8F6),
                                  ),
                                ),
                              ),
                              // frame
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  //  table
                                  Column(
                                    children: [
                                      Text('ТАБЛИЦА ПРЕДСКАЗАНИЙ',
                                        textAlign: TextAlign.center, 
                                        style: TextStyle(
                                          color: Color(0xFFFFFFFF),
                                          fontFamily: 'pobeda',
                                          fontSize: 45*fframe,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 5*fframe/frame,
                                          height: 1.3*fframe/frame,
                                        )
                                      ),
                                      SizedBox(
                                        height: 15*fframe,
                                      ),
                                      Container(
                                        width: 830*fframe,
                                        height: 500*fframe,
                                        decoration: BoxDecoration(
                                          // 0xFF305D50
                                          color: Color(0xFFFFFFFF),
                                          borderRadius: BorderRadius.circular(20.0*fframe),
                                        ),
                                        // padding: EdgeInsets.symmetric(horizontal: 30*fframe, vertical: 25*fframe),
                                        child: 
                                        SingleChildScrollView(
                                          scrollDirection: Axis.vertical,
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 30*fframe, vertical: 25*fframe),
                                            child: DataTable(
                                              dataRowMaxHeight: double.infinity,
                                              dataRowMinHeight: 65,
                                              dividerThickness: 1,
                                              showCheckboxColumn: false,
                                              sortAscending: true,
                                              columns: [
                                                DataColumn(label: 
                                                  Text('ИМЯ ФАЙЛА',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Color(0xFF000000),
                                                      fontFamily: 'Inter',
                                                      fontSize: 20*fframe,
                                                      fontWeight: FontWeight.w600,
                                                      letterSpacing: 1*fframe/frame,
                                                      height: 1.3*fframe,
                                                    ),
                                                  )
                                                ),
                                                DataColumn(label: 
                                                  Text('ПОДВИДЫ ОСОБЕЙ',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Color(0xFF000000),
                                                      fontFamily: 'Inter',
                                                      fontSize: 20*fframe,
                                                      fontWeight: FontWeight.w600,
                                                      letterSpacing: 1*fframe/frame,
                                                      height: 1.3*fframe,
                                                    ),
                                                  )
                                                ),
                                                DataColumn(label: 
                                                  Text('КОЛИЧЕСТВО',
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                      color: Color(0xFF000000),
                                                      fontFamily: 'Inter',
                                                      fontSize: 20*fframe,
                                                      fontWeight: FontWeight.w600,
                                                      letterSpacing: 1*fframe/frame,
                                                      height: 1.3*fframe,
                                                    ),
                                                  )
                                                ),
                                                
                                              ],
                                              rows: dataList.map((data) {
                                                return DataRow(
                                                  cells: [
                                                    DataCell(
                                                      Padding(
                                                        padding: EdgeInsets.symmetric(vertical: 10*fframe, horizontal: 5*fframe),
                                                        child: Text(shortcall(data.column1, 16),
                                                          textAlign: TextAlign.center,
                                                          style: TextStyle(
                                                            color: Color(0xFF000000),
                                                            fontFamily: 'Inter',
                                                            fontSize: 18*fframe,
                                                            fontWeight: FontWeight.w600,
                                                            letterSpacing: 2*fframe/frame,
                                                            height: 1.3*fframe,
                                                          ),
                                                        ),
                                                      )
                                                    ),
                                                    DataCell(
                                                      Padding(
                                                        padding: EdgeInsets.symmetric(vertical: 10*fframe, horizontal: 5*fframe),
                                                        child: Text(data.column3.join("\n\n"),
                                                          textAlign: TextAlign.center,
                                                          style: TextStyle(
                                                            color: Color(0xFF000000),
                                                            fontFamily: 'Inter',
                                                            fontSize: 18*fframe,
                                                            fontWeight: FontWeight.w600,
                                                            letterSpacing: 2*fframe/frame,
                                                            height: 1.3*fframe,
                                                          ),
                                                        ),
                                                      )
                                                    ),
                                                    DataCell(
                                                      Padding(
                                                        padding: EdgeInsets.symmetric(vertical: 10*fframe, horizontal: 5*fframe),
                                                        child: Text(data.column2,
                                                          textAlign: TextAlign.center,
                                                          style: TextStyle(
                                                            color: Color(0xFF000000),
                                                            fontFamily: 'Inter',
                                                            fontSize: 18*fframe,
                                                            fontWeight: FontWeight.w600,
                                                            letterSpacing: 2*fframe/frame,
                                                            height: 1.3*fframe,
                                                          ),
                                                        ),
                                                      )
                                                    ),
                                                  ],
                                                  onSelectChanged: (bool? selected) {
                                                    if (selected != null && selected) {
                                                      setState(() {
                                                        newfileargs.add(data.column1);
                                                        newfileargs.add(data.column2);
                                                        newfileargs.add(data.column3.join("\n\n"));
                                                      });
                                                      if (dataEmptyFlag == false) {
                                                        Navigator.push(
                                                          context,
                                                          PageRouteBuilder(
                                                            pageBuilder: (_, __, ___) =>  ExtImagesWidget(dataList: dataList, fileargs: newfileargs, images: images, dataEmptyFlag: dataEmptyFlag, prevpage: ImagesWidget(filesarr: filesarr, dataEmptyFlag: dataEmptyFlag, prevpage: prevpage, userData:userData), userData:userData),
                                                            transitionsBuilder: (_, animation, __, child) {
                                                              return FadeTransition(
                                                                opacity: animation,
                                                                child: child,
                                                              );
                                                            }
                                                          )
                                                        );
                                                      }
                                                      else {
                                                        newfileargs = [];
                                                      }
                                                    }
                                                  },
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        )
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 40*fframe,
                                  ),
                                  // instructions
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text('КАК ПОЛЬЗОВАТЬСЯ?',
                                        textAlign: TextAlign.center, 
                                        style: TextStyle(
                                          color: Color(0xFFFFFFFF),
                                          fontFamily: 'pobeda',
                                          fontSize: 42*fframe,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 5*fframe/frame,
                                          height: 1.3*fframe/frame,
                                        )
                                      ),
                                      SizedBox(
                                        height: 20*fframe,
                                      ),
                                      Container(
                                        width: 400*fframe,
                                        child: UnorderedList(const [
                                            "Загрузите ваши фото;",
                                            "Дождитесь обработки;",
                                            "Нажмите на нужную строку таблицы, чтобы детальнее изучить ее;",
                                            "Очистите таблицу кнопкой “Очистка”;",
                                            "Нажмите “Открыть json”, чтобы открыть папку с json-предсказанием модели.",
                                        ], frame),
                                      ),
                                      SizedBox(
                                        height: 20*fframe,
                                      ),
                                      Container(
                                        width: 400*fframe,
                                        height: 60*fframe,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: <Widget>[
                                            // download
                                            Container(
                                              height: 55*fframe,
                                              padding: EdgeInsets.symmetric(horizontal: 5*fframe, vertical: 0*fframe),
                                              decoration: BoxDecoration(
                                                color: Color(0xFFF9F8F6),
                                                borderRadius: BorderRadius.circular(20.0*fframe),
                                              ),
                                              child: MaterialButton(
                                                onPressed: () {
                                                  _fileProvider();
                                                },
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20.0*fframe),
                                                ),
                                                height: 55*fframe,
                                                child: Text('СКАЧАТЬ JSON', 
                                                  textAlign: TextAlign.center, 
                                                  style: TextStyle(
                                                    color: Color(0xFF000000),
                                                    fontFamily: 'Inter',
                                                    fontSize: 24*fframe,
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.3*fframe/frame,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // clear
                                            Container(
                                              height: 55*fframe,
                                              padding: EdgeInsets.symmetric(horizontal: 5*fframe, vertical: 0*fframe),
                                              decoration: BoxDecoration(
                                                color: Color(0xFFF9F8F6),
                                                borderRadius: BorderRadius.circular(20.0*fframe),
                                              ),
                                              child: MaterialButton(
                                                onPressed: () {
                                                  loadingFlag = false;
                                                  clearData();
                                                  dataEmptyFlag = true;
                                                },
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20.0*fframe),
                                                ),
                                                height: 55*fframe,
                                                child: Text('ОЧИСТКА', 
                                                  textAlign: TextAlign.center, 
                                                  style: TextStyle(
                                                    color: Color(0xFF000000),
                                                    fontFamily: 'Inter',
                                                    fontSize: 24*fframe,
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.3*fframe/frame,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
        
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}



class DataModel {
  final String column1;
  final String column2;
  final List<dynamic> column3;

  DataModel({required this.column1, required this.column2, required this.column3});

  factory DataModel.fromJson(Map<String, dynamic> json) {
    return DataModel(
      column1: json['column1'],
      column2: json['column2'],
      column3: json['column3'],
    );
  }
}