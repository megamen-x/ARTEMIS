// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace, unused_import, no_logic_in_create_state, prefer_typing_uninitialized_variables

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bitsdojo_window/bitsdojo_window.dart';

import '../../main.dart';
import '../main/welcome.dart';
import '../solution/images.dart';
import 'reg.dart';

class LoginWidget extends StatefulWidget {
  final prevpage;

  LoginWidget({super.key, @required this.prevpage,});

  @override
  State<LoginWidget> createState() => LoginState(prevpage: prevpage,);
}

class LoginState extends State<LoginWidget> {
  final prevpage;

  LoginState({@required this.prevpage,});
  
  Map userData = {
    "username": "Ваше имя пользователя",
    "email": "Ваша почта",
    "password": "Ваш пароль",
    "auth_token": "token",
  };

  final _formkey = GlobalKey<FormState>();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _pass = TextEditingController();

  bool _passwordVisible = false;
  bool _signError = false;

  Future<void> postUser(data, context) async {
    final json = data;
    try {
      final response = await http.post(
          Uri.parse('http://127.0.0.1:8000/auth/token/login/'),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: jsonEncode(json),
      );
      if (response.statusCode == 200) {
        _signError = false;

        final Map parsed = jsonDecode(response.body);
        data.update('auth_token', (value) => parsed['auth_token']);

        final responseData = await http.get(
          Uri.parse('http://127.0.0.1:8000/auth/users/me/'),
          headers: {
          "Authorization": 'Token ${data['auth_token']}'
          },
        );
        final Map parsedData = jsonDecode(responseData.body);
        data.update('email', (value) => parsedData['email']);
        List<DataModel> empty = [DataModel(column1: ' ', column2: ' ', column3: [' ',])];
        List<String> emptyList = ['', '', ''];
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) =>  ImagesWidget(filesarr: empty, dataEmptyFlag: true, prevpage: LoginWidget(prevpage: WelcomeWidget()), userData:userData, newLabelData: emptyList),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            }
          )
        );
      }
      else if (response.statusCode == 401) {
        setState(() {
          _signError = true;
        });
      }
      else if (response.statusCode == 400) {
        setState(() {
          _signError = true;
        });
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
  void initState() {
    super.initState();
    _passwordVisible = false;
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
                    padding: EdgeInsets.fromLTRB(20*fframe, 80*fframe, 20*fframe, 80*fframe),
                    child: 
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        // text
                        Text('АУТЕНТИФИКАЦИЯ',
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
                                              Text('Имя пользователя',
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
                                                  controller:  _username,
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
                                                    hintText: 'Введите имя пользователя',
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
                                                        fontWeight: FontWeight.w400,
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
                                              Text('Пароль',
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
                                                  controller: _pass,
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
                                                    hintText: 'Введите ваш пароль',
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
                                                        fontWeight: FontWeight.w400,
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
                                            userData.update('username', (value) => _username.text,);
                                            userData.update('password', (value) => _pass.text,);
                                            postUser(userData, context);
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
                                            fontSize: 23*fframe,
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('ВЫ СНОВА С НАМИ!',
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
                                  height: 175*fframe,
                                  child: UnorderedList(const [
                                      "Введите ваше имя пользователя и пароль;",
                                      "Подтверите отправку формы нажатием кнопки “Продолжить”."
                                  ], frame),
                                ),
                                SizedBox(
                                  height: 40*fframe,
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(0*fframe, 0*fframe, 10*fframe, 0*fframe),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text('У вас нет аккаунта?',
                                        textAlign: TextAlign.center, 
                                        style: TextStyle(
                                          color: Color(0xFFFFFFFF),
                                          fontFamily: 'Inter',
                                          fontSize: 23*fframe,
                                          fontWeight: FontWeight.w300,
                                          letterSpacing: 3*fframe/frame,
                                          height: 1.3*fframe/frame,
                                        )
                                      ),
                                      OutlinedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder: (_, __, ___) =>  RegWidget(prevpage: LoginWidget(prevpage: prevpage,)),
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
                                          padding: EdgeInsets.fromLTRB(7*frame, 20*frame, 7*frame, 20*frame),
                                          // backgroundColor: Color.fromARGB(21, 117, 117, 117),
                                          side: const BorderSide(color: Color(0xff14342B), width: 3),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0*fframe)),
                                        ),
                                        child: 
                                        Text('Зарегистрируйтесь здесь',
                                          textAlign: TextAlign.center, 
                                          style: TextStyle(
                                            color: Color(0xFF0BC776),
                                            fontFamily: 'Inter',
                                            fontSize: 23*fframe,
                                            fontWeight: FontWeight.w300,
                                            letterSpacing: 3*fframe/frame,
                                            height: 1.3*fframe/frame,
                                          )
                                        ),
                                      ),
                                    ],
                                  ),
                                )
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
          ),
        ),
      ),
    );
  }
}