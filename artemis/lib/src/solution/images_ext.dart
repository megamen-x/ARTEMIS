// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace, unused_import, no_logic_in_create_state, prefer_typing_uninitialized_variables

import 'dart:io';
import 'dart:convert';

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

import '../../main.dart';
import '../main/team.dart';
import '../system/account.dart';
import 'images.dart';

List <String> files = [];
String filepath = '';

class ExtImagesWidget extends StatefulWidget {
  final dataList, fileargs, images, dataEmptyFlag, prevpage, userData;

  ExtImagesWidget({super.key, @required this.dataList, this.fileargs, this.images, this.dataEmptyFlag, this.prevpage, this.userData});

  @override
  State<ExtImagesWidget> createState() => ExtImagesState(dataList: dataList, fileargs: fileargs, images: images, dataEmptyFlag: dataEmptyFlag, prevpage: prevpage, userData: userData);
}

class ExtImagesState extends State<ExtImagesWidget> {

  var dataList, fileargs, images, dataEmptyFlag, prevpage, userData;
  ExtImagesState({ @required this.dataList, this.fileargs, this.images, this.dataEmptyFlag, this.prevpage, this.userData});

  bool loadingFlag = false;
  bool dataClearFlag = false;
  bool buttonflag = false;

  var shortcall = ShortenFileName();
  final _imageController = PageController();

  List<String> myList = [
    'responce/deer_7.jpg',
    'responce/deer_10.jpg',
    'responce/deer_14.jpg',
    'responce/deer_18.jpg'
  ];

  String substring = 'deer.jpg';
  List<dynamic> matchingElements = [];
  int newindex = 0;

  void item() {
    substring = fileargs[0];
    newindex = images.indexOf(images.where((element) => element.contains(substring) as bool).toList()[0]);
  }

  @override
  void initState() {
    super.initState();
    item();
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
                                            pageBuilder: (_, __, ___) =>  ImagesWidget(filesarr: dataList, images: images, dataEmptyFlag: dataEmptyFlag, prevpage: prevpage, userData:userData),
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
                                            pageBuilder: (_, __, ___) =>  AccWidget(prevpage: prevpage, userData:userData),
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
                                            pageBuilder: (_, __, ___) =>  TeamWidget(prevpage: prevpage, userData:userData),
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // back
                        Container(
                          width: 60*fframe,
                          child: 
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                width: 50*fframe,
                                height: 50*fframe,
                                decoration: BoxDecoration (
                                    color: Color(0xFFF9F8F6),
                                    borderRadius: BorderRadius.circular(10.0*fframe),
                                ),
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (_, __, ___) =>  ImagesWidget(filesarr: dataList, images: images, dataEmptyFlag: dataEmptyFlag, prevpage: prevpage, userData:userData),
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
                                  child: Center(
                                    child: SvgPicture.asset(
                                      'assets/images/system/arrowleft.svg',
                                      semanticsLabel: 'Camera'
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 5*fframe,
                        ),
                        // main
                        Container(
                          width: 1360*fframe,
                          padding: EdgeInsets.fromLTRB(0*fframe, 0*fframe, 0*fframe, 0*fframe),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              // frame
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  //  text-input
                                  Container(
                                    width: 640*fframe,
                                    height: 640*fframe,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF305D50),
                                      borderRadius: BorderRadius.circular(20.0*fframe),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 15*fframe, vertical: 15*fframe),
                                    child: 
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        
                                        Container(
                                          width: 600*fframe,
                                          height: 600*fframe,
                                          decoration: BoxDecoration(
                                            color: Color(0xFF224138),
                                            borderRadius: BorderRadius.circular(12.0*fframe),
                                          ),
                                          child: 
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: PageView.builder(
                                              controller: _imageController,
                                              scrollDirection: Axis.horizontal,
                                              // itemCount: 1,
                                              itemBuilder: (context, index) {
                                                return ClipRRect(
                                                  child:
                                                    Image.file(File(images[newindex]),
                                                      height: 420*frame,
                                                      width: MediaQuery.of(context).size.width * 1,
                                                      fit: BoxFit.contain,
                                                    ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 40*fframe,
                                  ),
                                  Container(
                                    width: 6*fframe,
                                    height: 600*fframe,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF0BC776),
                                      borderRadius: BorderRadius.circular(20.0*fframe),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 40*fframe,
                                  ),
                                  // instructions
                                  Container(
                                    width: 580*fframe,
                                    height: 640*fframe,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF305D50),
                                      borderRadius: BorderRadius.circular(20.0*fframe),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 30*fframe, vertical: 40*fframe),
                                    child: 
                                    // file info
                                    Column(
                                      children: [
                                        Text('ДАННЫЕ О ФАЙЛЕ',
                                          textAlign: TextAlign.start, 
                                          style: TextStyle(
                                            color: Color(0xFFFFFFFF),
                                            fontFamily: 'pobeda',
                                            fontSize: 48*fframe,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 3*fframe/frame,
                                            height: 1.3*fframe/frame,
                                          )
                                        ),
                                        SizedBox(
                                          height: 30*fframe,
                                        ),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Color(0xFFF9F8F6),
                                                borderRadius: BorderRadius.circular(20.0*fframe),
                                                // border: Border.all(color: Color(0xFF0BC776), width: 3*fframe)
                                              ),
                                              padding: EdgeInsets.symmetric(horizontal: 15*fframe, vertical: 30*fframe),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('Название: ${shortcall(fileargs[0], 20)}',
                                                    textAlign: TextAlign.start, 
                                                    style: TextStyle(
                                                      color: Color(0xFF000000), 
                                                      fontFamily: 'Inter',
                                                      fontSize: 24*fframe,
                                                      fontWeight: FontWeight.w500,
                                                      letterSpacing: 1*fframe/frame,
                                                      height: 1.3*fframe/frame,
                                                    )
                                                  ),
                                                  SizedBox(
                                                    width: double.infinity,
                                                    height: 10*fframe,
                                                  ),
                                                  Text('Количество: ${fileargs[1]}',
                                                    textAlign: TextAlign.start, 
                                                    style: TextStyle(
                                                      color: Color(0xFF000000),
                                                      fontFamily: 'Inter',
                                                      fontSize: 24*fframe,
                                                      fontWeight: FontWeight.w500,
                                                      letterSpacing: 1*fframe/frame,
                                                      height: 1.3*fframe/frame,
                                                    )
                                                  ),
                                                  SizedBox(
                                                    width: double.infinity,
                                                    height: 10*fframe,
                                                  ),
                                                  Text('Виды: ${fileargs[2]}',
                                                    textAlign: TextAlign.start, 
                                                    style: TextStyle(
                                                      color: Color(0xFF000000),
                                                      fontFamily: 'Inter',
                                                      fontSize: 24*fframe,
                                                      fontWeight: FontWeight.w500,
                                                      letterSpacing: 1*fframe/frame,
                                                      height: 1.3*fframe/frame,
                                                    )
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: 70*fframe,
                                            ),
                                            
                                            SizedBox(
                                              width: double.infinity,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.all(5.0),
                                                    child: Text('Отметьте ниже - наличие ошибки\nв предсказании: ',
                                                      textAlign: TextAlign.start, 
                                                      style: TextStyle(
                                                        color: Color(0xFFEDEDED),
                                                        fontFamily: 'Inter',
                                                        fontSize: 24*fframe,
                                                        fontWeight: FontWeight.w400,
                                                        letterSpacing: 1*fframe/frame,
                                                        height: 1.3*fframe/frame,
                                                      )
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 20*fframe,
                                                  ),
                                                  Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        height: 55*fframe,
                                                        padding: EdgeInsets.symmetric(horizontal: 5*fframe, vertical: 0*fframe),
                                                        decoration: BoxDecoration(
                                                          // color: Color(0xFFF9F8F6),
                                                          borderRadius: BorderRadius.circular(20.0*fframe),
                                                          border: Border.all(color: Color(0xFF0BC776), width: 3*fframe)
                                                        ),
                                                        child: MaterialButton(
                                                          onPressed: () {
                                                            
                                                          },
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(20.0*fframe),
                                                          ),
                                                          height: 55*fframe,
                                                          child: Text('Ошибка детектора', 
                                                            textAlign: TextAlign.center, 
                                                            style: TextStyle(
                                                              color: Color(0xFFF9F8F6),
                                                              fontFamily: 'Inter',
                                                              fontSize: 24*fframe,
                                                              fontWeight: FontWeight.w500,
                                                              height: 1.3*fframe/frame,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 20*fframe,
                                                      ),
                                                      Container(
                                                        height: 55*fframe,
                                                        padding: EdgeInsets.symmetric(horizontal: 5*fframe, vertical: 0*fframe),
                                                        decoration: BoxDecoration(
                                                          // color: Color(0xFFF9F8F6),
                                                          borderRadius: BorderRadius.circular(20.0*fframe),
                                                          border: Border.all(color: Color(0xFF0BC776), width: 3*fframe)
                                                        ),
                                                        child: MaterialButton(
                                                          onPressed: () {
                                                            
                                                          },
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(20.0*fframe),
                                                          ),
                                                          height: 55*fframe,
                                                          child: Text('Ошибка классификатора', 
                                                            textAlign: TextAlign.center, 
                                                            style: TextStyle(
                                                              color: Color(0xFFF9F8F6),
                                                              fontFamily: 'Inter',
                                                              fontSize: 24*fframe,
                                                              fontWeight: FontWeight.w500,
                                                              height: 1.3*fframe/frame,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
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