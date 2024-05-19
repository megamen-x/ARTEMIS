// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace, unused_import, no_logic_in_create_state, prefer_typing_uninitialized_variables
import 'dart:io';
import 'dart:convert';
import 'package:LomaxApp/src/main/welcome.dart';
import 'package:LomaxApp/src/system/pass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:bitsdojo_window/bitsdojo_window.dart';

import '../../main.dart';
import '../main/team.dart';
import '../solution/images.dart';

class AccWidget extends StatefulWidget {
  
  final prevpage, userData;
  AccWidget({super.key,  @required this.prevpage, this.userData });

  @override
  State<AccWidget> createState() => AccState(prevpage: prevpage, userData: userData);
}

class AccState extends State<AccWidget> {

  final prevpage, userData;  
  AccState({@required this.prevpage, this.userData});
  
  bool history = false;
  var historyFiles = [];
  var shortcall = ShortenFileName();

  Future<void> userHistory(data) async {
    try {
      final responseData = await http.get(
        Uri.parse('http://127.0.0.1:8000/list_files/'),
        headers: {
        "Authorization": 'Token ${data['auth_token']}'
        },
      );
      final List parsedData = jsonDecode(responseData.body);
      List<String?> outputList = parsedData.map((item) {
        String? imageName;
        if (item['image'] != null) {
          String imageUrl = item['image'];
          imageName = imageUrl.split('/').last;
        }
        return imageName;
      }).toList();
      outputList.removeWhere((item) => item == null);
      setState(() {
        history = true;
        historyFiles = outputList;
      });
      
    } on SocketException {
      setState(() {
        Sample.AlshowDialog(context, 'Нет соединения с сервером!', 'Проверьте состояние сервера и попробуйте снова');
      });
    } on HttpException {
      setState(() {
        Sample.AlshowDialog(context, "Не удалось найти метод post!", 'Проверьте состояние сервера и попробуйте снова');
      });
    } on FormatException {
      setState(() {
        Sample.AlshowDialog(context, "Неправильный формат ответа!", 'Проверьте состояние сервера и попробуйте снова');
      });
    }
  }


  @override
  void initState() {
    super.initState();
    userHistory(userData);
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
                                        List<DataModel> empty = [DataModel(column1: ' ', column2: ' ', column3: [' ',])];
                                        List<String> emptyList = ['', '', ''];
                                        Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (_, __, ___) =>  ImagesWidget(filesarr: empty, dataEmptyFlag: false, prevpage: prevpage, userData:userData, newLabelData: emptyList),
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
                    padding: EdgeInsets.fromLTRB(20*fframe, 80*fframe, 20*fframe, 30*fframe),
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
                                    List<DataModel> empty = [DataModel(column1: ' ', column2: ' ', column3: [' ',])];
                                    List<String> emptyList = ['', '', ''];
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (_, __, ___) =>  ImagesWidget(filesarr: empty, dataEmptyFlag: false, prevpage: prevpage, userData:userData, newLabelData: emptyList),
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
                          width: 30*fframe,
                        ),
                        // main
                        Container(
                          width: 1360*fframe,
                          padding: EdgeInsets.fromLTRB(0*fframe, 0*fframe, 0*fframe, 50*fframe),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              // text
                              Text('ВАШ АККАУНТ',
                                textAlign: TextAlign.center, 
                                style: TextStyle(
                                  color: Color(0xFFFFFFFF),
                                  fontFamily: 'pobeda',
                                  fontSize: 55*fframe,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 5*fframe/frame,
                                  height: 1.3*fframe/frame,
                                )
                              ),
                              // frame
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  //  text-input
                                  Container(
                                    width: 450*fframe,
                                    height: 400*fframe,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF305D50),
                                      borderRadius: BorderRadius.circular(20.0*fframe),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 15*fframe, vertical: 25*fframe),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        // username
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Имя пользователя',
                                              textAlign: TextAlign.start, 
                                              style: TextStyle(
                                                color: Color(0xFFEDEDED),
                                                fontFamily: 'Inter',
                                                fontSize: 24*fframe,
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: 1*fframe/frame,
                                                height: 1.3*fframe/frame,
                                              )
                                            ),
                                            SizedBox(
                                              height: 10*fframe,
                                            ),
                                            Container(
                                              width: 420*fframe,
                                              height: 55*fframe,
                                              decoration: BoxDecoration (
                                                  color: Color(0xFFF9F8F6),
                                                  borderRadius: BorderRadius.circular(10.0*fframe)
                                              ),
                                              padding: EdgeInsets.symmetric(horizontal: 15*fframe, vertical: 15*fframe),
                                              child: Text(
                                                (userData['username'].isEmpty) ?  'Имя аккаунта не найдено' : userData['username'] ,
                                                textAlign: TextAlign.start, 
                                                style: TextStyle(
                                                  color: Color(0xFF000000),
                                                  fontFamily: 'Inter',
                                                  fontSize: 23*fframe,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 1*fframe/frame,
                                                  height: 1.3*fframe/frame,
                                                )
                                              ),
                                            ),
                                          ],
                                        ),
                                        //  email
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Почта',
                                              textAlign: TextAlign.start, 
                                              style: TextStyle(
                                                color: Color(0xFFEDEDED),
                                                fontFamily: 'Inter',
                                                fontSize: 24*fframe,
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: 1*fframe/frame,
                                                height: 1.3*fframe/frame,
                                              )
                                            ),
                                            SizedBox(
                                              height: 10*fframe,
                                            ),
                                            Container(
                                              width: 420*fframe,
                                              height: 55*fframe,
                                              decoration: BoxDecoration (
                                                  color: Color(0xFFF9F8F6),
                                                  borderRadius: BorderRadius.circular(10.0*fframe)
                                              ),
                                              padding: EdgeInsets.fromLTRB(15*fframe, 15*fframe, 15*fframe, 0*fframe),
                                              child: Text(
                                                (userData['email'].isEmpty) ?  'Имя аккаунта не найдено' : userData['email'] ,
                                                textAlign: TextAlign.start, 
                                                style: TextStyle(
                                                  color: Color(0xFF000000),
                                                  fontFamily: 'Inter',
                                                  fontSize: 23*fframe,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 1*fframe/frame,
                                                  height: 1.3*fframe/frame,
                                                )
                                              ),
                                            ),
                                          ],
                                        ),
                                        // btn pass
                                        Container(
                                          width: 300*fframe,
                                          height: 55*fframe,
                                          decoration: BoxDecoration(
                                            color: Color(0xFF0A3725),
                                            borderRadius: BorderRadius.circular(20.0*fframe),
                                          ),
                                          child: MaterialButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                  pageBuilder: (_, __, ___) =>  PassWidget(prevpage: prevpage, userData: userData),
                                                  transitionsBuilder: (_, animation, __, child) {
                                                    return FadeTransition(
                                                      opacity: animation,
                                                      child: child,
                                                    );
                                                  }
                                                )
                                              );
                                            },
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20.0*fframe),
                                            ),
                                            height: 55*fframe,
                                            child: Text('ИЗМЕНИТЬ ПАРОЛЬ', 
                                              textAlign: TextAlign.center, 
                                              style: TextStyle(
                                                color: Color(0xFFFFFFFF),
                                                fontFamily: 'Inter',
                                                fontSize: 24*fframe,
                                                fontWeight: FontWeight.w700,
                                                height: 1.3*fframe/frame,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // btn exit
                                        Container(
                                          width: 300*fframe,
                                          height: 55*fframe,
                                          decoration: BoxDecoration(
                                            color: Color(0xFF0A3725),
                                            borderRadius: BorderRadius.circular(20.0*fframe),
                                          ),
                                          child: MaterialButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                  pageBuilder: (_, __, ___) =>  WelcomeWidget(),
                                                  transitionsBuilder: (_, animation, __, child) {
                                                    return FadeTransition(
                                                      opacity: animation,
                                                      child: child,
                                                    );
                                                  }
                                                )
                                              );
                                            },
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20.0*fframe),
                                            ),
                                            height: 55*fframe,
                                            child: Text('ВЫЙТИ ИЗ АККАУНТА', 
                                              textAlign: TextAlign.center, 
                                              style: TextStyle(
                                                color: Color(0xFFFFFFFF),
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
                                  SizedBox(
                                    width: 40*fframe,
                                  ),
                                  // instructions
                                   Container(
                                    width: 450*fframe,
                                    height: 400*fframe,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF305D50),
                                      borderRadius: BorderRadius.circular(20.0*fframe),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 15*fframe, vertical: 25*fframe),
                                    child: 
                                    // files
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Загруженные файлы',
                                          textAlign: TextAlign.start, 
                                          style: TextStyle(
                                            color: Color(0xFFEDEDED),
                                            fontFamily: 'Inter',
                                            fontSize: 24*fframe,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 1*fframe/frame,
                                            height: 1.3*fframe/frame,
                                          )
                                        ),
                                        SizedBox(
                                          height: 10*fframe,
                                        ),
                                        if (history)
                                        Container(
                                          width: 420*fframe,
                                          height: 250*fframe,
                                          decoration: BoxDecoration (
                                              color: Color(0xFFF9F8F6),
                                              borderRadius: BorderRadius.circular(10.0*fframe)
                                          ),
                                          padding: EdgeInsets.symmetric(horizontal: 15*fframe, vertical: 15*fframe),
                                          child: ListView.builder(
                                            itemCount: historyFiles.length,
                                            itemBuilder: (context, index) {
                                              return Container(
                                                margin: EdgeInsets.only(bottom: 10*fframe),
                                                child: Text(
                                                  '${index+1}. ${shortcall(historyFiles[index], 25)}' ,
                                                  textAlign: TextAlign.start, 
                                                  style: TextStyle(
                                                    color: Color(0xFF000000),
                                                    fontFamily: 'JetBrainsMono',
                                                    fontSize: 22*fframe,
                                                    fontWeight: FontWeight.w200,
                                                    letterSpacing: 0,
                                                    height: 1.3*fframe/frame,
                                                  )
                                                ),
                                              );
                                            }
                                          ),
                                        )
                                        else
                                        Container(
                                          width: 420*fframe,
                                          height: 250*fframe,
                                          decoration: BoxDecoration (
                                              color: Color(0xFFF9F8F6),
                                              borderRadius: BorderRadius.circular(10.0*fframe)
                                          ),
                                          padding: EdgeInsets.symmetric(horizontal: 15*fframe, vertical: 15*fframe),
                                          
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