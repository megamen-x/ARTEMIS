// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace, unused_import, no_logic_in_create_state, prefer_typing_uninitialized_variables

import 'dart:io';
import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http_parser/http_parser.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import '../../main.dart';
import '../main/team.dart';
import '../system/account.dart';
import 'images.dart';
import 'images_ext.dart';

List <String> files = [];
String filepath = '';

Uri fileprovider = Uri.parse('file:///$filepath');

class VideosWidget extends StatefulWidget {
  final filesarr, dataEmptyFlag, prevpage, userData;

  VideosWidget({super.key, @required this.filesarr, this.dataEmptyFlag, this.prevpage, this.userData});

  @override
  State<VideosWidget> createState() => VideosState(filesarr: filesarr, dataEmptyFlag: dataEmptyFlag, prevpage: prevpage, userData: userData);
}

class VideosState extends State<VideosWidget> {

  var filesarr, dataEmptyFlag, prevpage, userData;
  VideosState({ @required this.filesarr, this.dataEmptyFlag, this.prevpage, this.userData});

  bool loadingFlag = false;
  bool dataClearFlag = false;

  Future<void> _fileProvider() async {
    if (!await launchUrl(fileprovider)) {
      throw Exception('Could not launch $fileprovider');
    }
  }

  // test
  List<DataModel> dataList = [
    DataModel(column1: 'file-name1', column2: '25', column3: ['Deer',]),
    DataModel(column1: 'file-name2', column2: '30', column3: ['MuskDeer']),
    DataModel(column1: 'file-name3', column2: '35', column3: ['RoeDeer']),
  ];
  //

  // image upload to fastapi server
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
          loadingFlag = false;
          dataList = [];
          var tmp = dataMap.length;
          for (var i = 0; i < tmp; i++) {
            DataModel newData = DataModel.fromJson(dataMap[i]);
            dataList.add(newData);
          }
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

  Future<void> clearData() async {
    if (Platform.isWindows || Platform.isLinux) {
      filesarr = [
        "./assets/images/loader.png",
      ];
      deleteFilesInFolder("./responce");
    }
    setState(() {
      dataEmptyFlag = false;
    });
  }

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

  Future<void> unzipFileFromResponse(List<int> responseBody) async {
    final archive = ZipDecoder().decodeBytes(responseBody);
    filesarr = [];
    for (final file in archive) {
      final filename = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        if (filename.contains('.jpg') || filename.contains('.jpeg') || filename.contains('.png') || filename.contains('.bmp')) {
          if (Platform.isWindows || Platform.isLinux) {
            File('./responce/$filename')
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
            filesarr.add('./responce/$filename');
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
                                            pageBuilder: (_, __, ___) =>  ImagesWidget(filesarr: filesarr, dataEmptyFlag: dataEmptyFlag, prevpage: ImagesWidget(filesarr: filesarr, dataEmptyFlag: dataEmptyFlag, prevpage: prevpage, userData:userData), userData:userData),
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
                          width: 1460*fframe,
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
                                    loadingFlag ? 'ОБРАБОТКА...' : 'ВЫБРАТЬ ВИДЕО',
                                    style: TextStyle(
                                      fontFamily: 'Inter', 
                                      fontSize: 23*fframe,
                                      fontWeight: FontWeight.w700,
                                      height: 1.3*fframe/frame,
                                      color: Color(0xFF000000),
                                    ),
                                  ),
                                  // onPressed: () => loadingFlag ? null : uploadImage(context),
                                  onPressed: () {},
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text('ОБРАБОТАННОЕ ВИДЕО',
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
                                        height: 10*fframe,
                                      ),
                                      Container(
                                        width: 830*fframe,
                                        height: 500*fframe,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFFFFFFF),
                                          borderRadius: BorderRadius.circular(20.0*fframe),
                                        ),
                                        padding: EdgeInsets.symmetric(horizontal: 5*fframe, vertical: 5*fframe),
                                        child: Container(
                                          width: double.infinity,
                                          height: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Color(0xFF000000),
                                            borderRadius: BorderRadius.circular(15.0*fframe),
                                          ),
                                          padding: EdgeInsets.symmetric(horizontal: 3*fframe, vertical: 3*fframe),
                                          
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 40*fframe,
                                  ),
                                  // instructions
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text('АННОТАЦИЯ',
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
                                        height: 10*fframe,
                                      ),
                                      Container(
                                        width: 500*fframe,
                                        height: 500*fframe,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFFFFFFF),
                                          borderRadius: BorderRadius.circular(20.0*fframe),
                                        ),
                                        padding: EdgeInsets.symmetric(horizontal: 15*fframe, vertical: 25*fframe),
                                        
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