// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace, unused_import, no_logic_in_create_state, prefer_typing_uninitialized_variables

import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import '../../main.dart';
import '../solution/images.dart';
import '../system/account.dart';

final Uri githubMMT = Uri.parse('https://github.com/orgs/megamen-x/repositories');
final Uri whatisslove7 = Uri.parse('https://t.me/whatisslove7');
final Uri asitcomes = Uri.parse('https://t.me/asitcomes');
final Uri agar1us = Uri.parse('https://t.me/agar1us');
final Uri al_goodini= Uri.parse('https://t.me/al_goodini');

class TeamWidget extends StatefulWidget {
  final prevpage, userData;

  TeamWidget({ super.key,  @required this.prevpage, this.userData});

  @override
  State<TeamWidget> createState() => TeamState(prevpage: prevpage, userData: userData);
}

class TeamState extends State<TeamWidget> {

  final prevpage, userData;
  TeamState({ @required this.prevpage, this.userData});

  Future<void> _launchUrl(param) async {
    if (param == 'github') {
      if (!await launchUrl(githubMMT)) {
        throw Exception('Could not launch $githubMMT');
      }
    }
    else if (param == 'vlad') {
      if (!await launchUrl(whatisslove7)) {
        throw Exception('Could not launch $whatisslove7');
      }
    }
    else if (param == 'egor') {
      if (!await launchUrl(asitcomes)) {
        throw Exception('Could not launch $asitcomes');
      }
    }
    else if (param == 'sasha') {
      if (!await launchUrl(agar1us)) {
        throw Exception('Could not launch $agar1us');
      }
    }
    else if (param == 'leha') {
      if (!await launchUrl(al_goodini)) {
        throw Exception('Could not launch $al_goodini');
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
                                        Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (_, __, ___) =>  ImagesWidget(filesarr: empty, dataEmptyFlag: true, prevpage: prevpage, userData:userData, newLabelData: []),
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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                width: 345*fframe,
                                height: 90*fframe,
                                decoration: BoxDecoration(
                                  color: Color(0xFFF9F8F6),
                                  borderRadius: BorderRadius.circular(20.0*fframe),
                                ),
                                child:
                                MaterialButton(
                                  onPressed: () {
                                    _launchUrl('github');
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0*fframe),
                                  ),
                                  height: 55*fframe,
                                  child: Text('megamen', 
                                    textAlign: TextAlign.center, 
                                    style: TextStyle(
                                      color: Color(0xFF000000),
                                      fontFamily: 'Limelight',
                                      fontSize: 48*fframe,
                                      fontWeight: FontWeight.w400,
                                      height: 1.0*fframe/frame,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 40*fframe,
                              ),
                              // frame
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  //  vlad
                                  Container(
                                    width: 540*fframe,
                                    height: 240*fframe,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF305D50),
                                      borderRadius: BorderRadius.circular(20.0*fframe),
                                    ),
                                    padding: EdgeInsets.fromLTRB(40*fframe, 0*fframe, 50*fframe, 0*fframe),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center ,
                                      children: [
                                        Container(
                                          width: 200*fframe,
                                          height: 200*fframe,
                                          decoration: BoxDecoration (
                                              borderRadius: BorderRadius.circular(20.0*fframe)
                                          ),
                                          child: Image.asset(
                                            'assets/images/team/mmt-vlad.png',
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ),
                                        Container(
                                          height: 200*fframe,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              Column(
                                                children: [
                                                  Text('ПОЛЕТАЕВ\nВЛАДИСЛАВ',
                                                    textAlign: TextAlign.center, 
                                                    style: TextStyle(
                                                      color: Color(0xFFEDEDED),
                                                      fontFamily: 'Inter',
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.w600,
                                                      height: 1.3*fframe/frame,
                                                    ),
                                                  ),
                                                  Text('- ML ИНЖЕНЕР -',
                                                    textAlign: TextAlign.center, 
                                                    style: TextStyle(
                                                      color: Color(0xFFEDEDED),
                                                      fontFamily: 'Inter',
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.w600,
                                                      height: 1.3*fframe/frame,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              MaterialButton(
                                                onPressed: () {
                                                  _launchUrl('vlad');
                                                },
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20.0*fframe),
                                                ),
                                                height: 55*fframe,
                                                child: Text('@whatisslove7',
                                                  textAlign: TextAlign.center, 
                                                  style: TextStyle(
                                                    color: Color(0xFFEDEDED),
                                                    fontFamily: 'JetBrainsMono',
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.3*fframe/frame,
                                                  ),
                                                ),
                                              )
                                            ]
                                          )
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 40*fframe,
                                  ),
                                  // egor
                                  Container(
                                    width: 540*fframe,
                                    height: 240*fframe,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF305D50),
                                      borderRadius: BorderRadius.circular(20.0*fframe),
                                    ),
                                    padding: EdgeInsets.fromLTRB(40*fframe, 0*fframe, 65*fframe, 0*fframe),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center ,
                                      children: [
                                        Container(
                                          width: 200*fframe,
                                          height: 200*fframe,
                                          decoration: BoxDecoration (
                                              borderRadius: BorderRadius.circular(20.0*fframe)
                                          ),
                                          child: Image.asset(
                                            'assets/images/team/mmt-egor.png',
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ),
                                        Container(
                                          height: 200*fframe,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              Column(
                                                children: [
                                                  Text('ЧУФИСТОВ\nГЕОРГИЙ',
                                                    textAlign: TextAlign.center, 
                                                    style: TextStyle(
                                                      color: Color(0xFFEDEDED),
                                                      fontFamily: 'Inter',
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.w600,
                                                      height: 1.3*fframe/frame,
                                                    ),
                                                  ),
                                                  Text('- BACKEND -',
                                                    textAlign: TextAlign.center, 
                                                    style: TextStyle(
                                                      color: Color(0xFFEDEDED),
                                                      fontFamily: 'Inter',
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.w600,
                                                      height: 1.3*fframe/frame,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              MaterialButton(
                                                onPressed: () {
                                                  _launchUrl('egor');
                                                },
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20.0*fframe),
                                                ),
                                                height: 55*fframe,
                                                child: Text('@asitcomes',
                                                  textAlign: TextAlign.center, 
                                                  style: TextStyle(
                                                    color: Color(0xFFEDEDED),
                                                    fontFamily: 'JetBrainsMono',
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.3*fframe/frame,
                                                  ),
                                                ),
                                              )
                                            ]
                                          )
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 40*fframe,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  //  sasha
                                  Container(
                                    width: 540*fframe,
                                    height: 240*fframe,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF305D50),
                                      borderRadius: BorderRadius.circular(20.0*fframe),
                                    ),
                                    padding: EdgeInsets.fromLTRB(40*fframe, 0*fframe, 50*fframe, 0*fframe),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center ,
                                      children: [
                                        Container(
                                          width: 200*fframe,
                                          height: 200*fframe,
                                          decoration: BoxDecoration (
                                              borderRadius: BorderRadius.circular(20.0*fframe)
                                          ),
                                          child: Image.asset(
                                            'assets/images/team/mmt-sasha.png',
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ),
                                        Container(
                                          height: 200*fframe,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              Column(
                                                children: [
                                                  Text('КАЛИНИН\nАЛЕКСАНДР',
                                                    textAlign: TextAlign.center, 
                                                    style: TextStyle(
                                                      color: Color(0xFFEDEDED),
                                                      fontFamily: 'Inter',
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.w600,
                                                      height: 1.3*fframe/frame,
                                                    ),
                                                  ),
                                                  Text('- ML ИНЖЕНЕР -',
                                                    textAlign: TextAlign.center, 
                                                    style: TextStyle(
                                                      color: Color(0xFFEDEDED),
                                                      fontFamily: 'Inter',
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.w600,
                                                      height: 1.3*fframe/frame,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              MaterialButton(
                                                onPressed: () {
                                                  _launchUrl('sasha');
                                                },
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20.0*fframe),
                                                ),
                                                height: 55*fframe,
                                                child: Text('@agar1us',
                                                  textAlign: TextAlign.center, 
                                                  style: TextStyle(
                                                    color: Color(0xFFEDEDED),
                                                    fontFamily: 'JetBrainsMono',
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.3*fframe/frame,
                                                  ),
                                                ),
                                              )
                                            ]
                                          )
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 40*fframe,
                                  ),
                                  // leha
                                  Container(
                                    width: 540*fframe,
                                    height: 240*fframe,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF305D50),
                                      borderRadius: BorderRadius.circular(20.0*fframe),
                                    ),
                                    padding: EdgeInsets.fromLTRB(40*fframe, 0*fframe, 60*fframe, 0*fframe),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center ,
                                      children: [
                                        Container(
                                          width: 200*fframe,
                                          height: 200*fframe,
                                          decoration: BoxDecoration (
                                              borderRadius: BorderRadius.circular(20.0*fframe)
                                          ),
                                          child: Image.asset(
                                            'assets/images/team/mmt-leha.png',
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ),
                                        Container(
                                          height: 200*fframe,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              Column(
                                                children: [
                                                  Text('ЛУНЯКОВ\nАЛЕКСЕЙ',
                                                    textAlign: TextAlign.center, 
                                                    style: TextStyle(
                                                      color: Color(0xFFEDEDED),
                                                      fontFamily: 'Inter',
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.w600,
                                                      height: 1.3*fframe/frame,
                                                    ),
                                                  ),
                                                  Text('- FRONTEND -',
                                                    textAlign: TextAlign.center, 
                                                    style: TextStyle(
                                                      color: Color(0xFFEDEDED),
                                                      fontFamily: 'Inter',
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.w600,
                                                      height: 1.3*fframe/frame,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              MaterialButton(
                                                onPressed: () {
                                                  _launchUrl('leha');
                                                },
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20.0*fframe),
                                                ),
                                                height: 55*fframe,
                                                child: Text('@al_goodini',
                                                  textAlign: TextAlign.center, 
                                                  style: TextStyle(
                                                    color: Color(0xFFEDEDED),
                                                    fontFamily: 'JetBrainsMono',
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.3*fframe/frame,
                                                  ),
                                                ),
                                              )
                                            ]
                                          )
                                        )
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