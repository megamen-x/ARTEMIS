// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace, unused_import, no_logic_in_create_state, prefer_typing_uninitialized_variables
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:form_field_validator/form_field_validator.dart';

import '../../main.dart';
import './account.dart';

class PassWidget extends StatefulWidget {
  final prevpage, userData;

  PassWidget({super.key, @required this.prevpage,this.userData,});

  @override
  State<PassWidget> createState() => PassState(prevpage: prevpage, userData: userData);
}

class PassState extends State<PassWidget> {
  final prevpage, userData;

  PassState({@required this.prevpage,this.userData,});

  final _formkey = GlobalKey<FormState>();
  final TextEditingController _newPass = TextEditingController();
  final TextEditingController _oldPass = TextEditingController();

  bool responceFlag = false;
  bool _passwordVisible = false;
  bool _passwordVisible2 = false;
  bool _signError = false;
  var newPass = '';

  Future<void> postPassword(data, newPass, context) async {
    setState(() {
      responceFlag = true;
    });

    final json = data;
    String oldPass = json['password'];
    try {
      final response = await http.put(
          Uri.parse('http://127.0.0.1:8000/change/'),
          headers: {
            'Authorization': 'Token ${data['auth_token']}',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'old_password': oldPass,
            'new_password': newPass,
          }),
      );
      dynamic newPassw = jsonDecode('{"password":"$newPass"}');
      if (response.statusCode == 204) {
        userData.update('password', (value) => newPassw["password"]);
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => AccWidget(prevpage: PassWidget(prevpage: prevpage, userData: userData), userData: userData),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            }
          )
        );
      }
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
                                            pageBuilder: (_, __, ___) =>  prevpage,
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
                                            pageBuilder: (_, __, ___) =>  prevpage,
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
                                            pageBuilder: (_, __, ___) =>  prevpage,
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
                      children: [
                        Container(
                          width: 60*fframe,
                          // height: 710*fframe,
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
                        Container(
                          width: 1360*fframe,
                          padding: EdgeInsets.fromLTRB(0*fframe, 0*fframe, 0*fframe, 50*fframe),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              // text
                              Text('ИЗМЕНЕНИЕ ПАРОЛЯ',
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
                                    width: 440*fframe,
                                    height: 380*fframe,
                                    child: Form(
                                      key: _formkey,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: <Widget>[
                                              // username
                                              Container(
                                                width: 400*fframe,
                                                decoration: BoxDecoration (
                                                    color: Color(0xFF305D50),
                                                    borderRadius: BorderRadius.circular(20.0*fframe)
                                                ),
                                                margin: EdgeInsets.fromLTRB(0*fframe, 0*fframe, 0*fframe, 20*fframe),
                                                padding: EdgeInsets.symmetric(horizontal: 15*fframe, vertical: 15*fframe),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text('Старый пароль',
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
                                                    Container(
                                                      margin: EdgeInsets.fromLTRB(0*fframe, 15*fframe, 0*fframe, 0*fframe),
                                                      decoration: BoxDecoration (
                                                          color: Color(0xFFFFFFFF),
                                                          borderRadius: BorderRadius.circular(20.0*fframe)
                                                      ),
                                                      child: TextFormField(
                                                        controller:  _oldPass,
                                                        obscureText: !_passwordVisible2,
                                                        cursorColor: Color(0xff1D1D1B),
                                                        style: TextStyle(
                                                            fontFamily: 'Inter',
                                                              fontSize: 24*fframe,
                                                              fontWeight: FontWeight.w600,
                                                              height: 1.3*fframe/frame,
                                                              color: Color(0xFF1D1D1B),
                                                          ),
                                                        decoration: InputDecoration(
                                                          labelText: '',
                                                          hintText: 'Введите ваш старый пароль',
                                                          // style
                                                          labelStyle: TextStyle(
                                                            fontFamily: 'Inter',
                                                              fontSize: 24*fframe,
                                                              fontWeight: FontWeight.w400,
                                                              height: 1.3*fframe/frame,
                                                              color: Color(0xff606060),
                                                          ),
                                                          hintStyle: TextStyle(
                                                            fontFamily: 'Inter',
                                                              fontSize: 24*fframe,
                                                              fontWeight: FontWeight.w300,
                                                              height: 1.3*fframe/frame,
                                                              color: Color(0xff606060),
                                                          ),
                                                          focusedBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                              color: _signError
                                                              ?Color(0xffA10912)
                                                              : Color(0xFFFFFFFF),
                                                              width: 2
                                                            ),
                                                            borderRadius: BorderRadius.all(Radius.circular(20*fframe)),
                                                          ),
                                                          enabledBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                              color: _signError
                                                              ?Color(0xffA10912)
                                                              : Color(0xFFFFFFFF),
                                                              width: 3
                                                            ),
                                                            borderRadius: BorderRadius.all(Radius.circular(20*fframe)),
                                                          ),
                                                          suffixIcon: Padding(
                                                            padding: EdgeInsets.all(10.0*fframe),
                                                            child: IconButton(
                                                              icon: Icon(
                                                                _passwordVisible2
                                                                ? Icons.visibility
                                                                : Icons.visibility_off,
                                                                color: Color.fromARGB(255, 0, 0, 0),
                                                              ),
                                                              onPressed: () {
                                                                setState(() {
                                                                    _passwordVisible2 = !_passwordVisible2;
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                        //
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              
                                              //  password 
                                              Container(
                                                width: 400*fframe,
                                                decoration: BoxDecoration (
                                                    color: Color(0xFF305D50),
                                                    borderRadius: BorderRadius.circular(20.0*fframe)
                                                ),
                                                padding: EdgeInsets.symmetric(horizontal: 15*fframe, vertical: 15*fframe),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text('Новый пароль',
                                                      textAlign: TextAlign.start, 
                                                      style: TextStyle(
                                                        color: Color(0xFFEDEDED),
                                                        fontFamily: 'Inter',
                                                        fontSize: 24*fframe,
                                                        fontWeight: FontWeight.w400,
                                                        letterSpacing: 0,
                                                        height: 1.3*fframe/frame,
                                                      )
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.fromLTRB(0*fframe, 15*fframe, 0*fframe, 0*fframe),
                                                      decoration: BoxDecoration (
                                                          color: Color(0xFFFFFFFF),
                                                          borderRadius: BorderRadius.circular(20.0*fframe)
                                                      ),
                                                      child: TextFormField(
                                                        controller: _newPass,
                                                        obscureText: !_passwordVisible,
                                                        cursorColor: Color(0xff1D1D1B),
                                                        style: TextStyle(
                                                            fontFamily: 'Inter',
                                                              fontSize: 22*fframe,
                                                              fontWeight: FontWeight.w600,
                                                              height: 1.3*fframe/frame,
                                                              color: Color(0xFF1D1D1B),
                                                          ),
                                                        decoration: InputDecoration(
                                                          hintText: 'Введите ваш новый пароль',
                                                          labelText: '',
                                                          // style
                                                          labelStyle: TextStyle(
                                                            fontFamily: 'Inter',
                                                              fontSize: 22*fframe,
                                                              fontWeight: FontWeight.w400,
                                                              height: 1.3*fframe/frame,
                                                              color: Color(0xff606060),
                                                          ),
                                                          hintStyle: TextStyle(
                                                            fontFamily: 'Inter',
                                                              fontSize: 22*fframe,
                                                              fontWeight: FontWeight.w300,
                                                              height: 1.3*fframe/frame,
                                                              color: Color(0xff606060),
                                                          ),
                                                          suffixIcon: Padding(
                                                            padding: EdgeInsets.all(10.0*fframe),
                                                            child: IconButton(
                                                              icon: Icon(
                                                                _passwordVisible
                                                                ? Icons.visibility
                                                                : Icons.visibility_off,
                                                                color: Color.fromARGB(255, 0, 0, 0),
                                                              ),
                                                              onPressed: () {
                                                                setState(() {
                                                                    _passwordVisible = !_passwordVisible;
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                          focusedBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                              color: _signError
                                                              ?Color(0xffA10912)
                                                              : Color(0xFFFFFFFF),
                                                              width: 2
                                                            ),
                                                            borderRadius: BorderRadius.all(Radius.circular(20*fframe)),
                                                          ),
                                                          enabledBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                              color: _signError
                                                              ?Color(0xffA10912)
                                                              : Color(0xFFFFFFFF),
                                                              width: 3
                                                            ),
                                                            borderRadius: BorderRadius.all(Radius.circular(20*fframe)),
                                                          ),
                                                        ),
                                                        //
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          //  button
                                          Container(
                                            width: 225*fframe,
                                            height: 55*fframe,
                                            decoration: BoxDecoration(
                                              color: Color(0xFFF9F8F6),
                                              borderRadius: BorderRadius.circular(20.0*fframe),
                                            ),
                                            child: MaterialButton(
                                              onPressed: () {
                                                if (_formkey.currentState!.validate()) { 
                                                  if (_formkey.currentState!.validate()) { 
                                                    userData.update('password', (value) => _oldPass.text,);
                                                    newPass = _newPass.text;
                                                    postPassword(userData, newPass, context);
                                                  }
                                                }
                                              },
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20.0*fframe),
                                              ),
                                              height: 55*fframe,
                                              child: Text('ПРОДОЛЖИТЬ', 
                                                textAlign: TextAlign.center, 
                                                style: TextStyle(
                                                  color: Color(0xFF000000),
                                                  fontFamily: 'Inter',
                                                  fontSize: 26*fframe,
                                                  fontWeight: FontWeight.w700,
                                                  height: 1.3*fframe/frame,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 40*fframe,
                                  ),
                                  // instructions
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('КАК ПОМЕНЯТЬ ПАРОЛЬ?',
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
                                        height: 225*fframe,
                                        child: UnorderedList(const [
                                            "Введите ваш старый пароль;",
                                            "Придумайте и запишите ваш новый пароль;",
                                            "Подтверите отправку формы нажатием кнопки “Продолжить”."
                                        ], frame),
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
