import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:path/path.dart' as path;
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';

import 'src/main/welcome.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Window.initialize();
  if (Platform.isWindows) {
    await Window.hideWindowControls();
  }
  // FlutterError.onError = (details) {
  //   FlutterError.presentError(details);
  //   if (kReleaseMode) exit(1);
  // };
  runApp(const MyApp());
  if (Platform.isWindows) {
    doWhenWindowReady(() {
      appWindow
        ..size = const Size(1550, 870)
        ..alignment = Alignment.center
        ..title = "ARTEMIS"
        ..maxSize = const Size(1550, 870)
        ..minSize = const Size(1550, 870)
        ..show();
    });
  }
  if (Platform.isLinux) {
    doWhenWindowReady(() {
      appWindow
        ..size = const Size(1069, 600)
        ..alignment = Alignment.center
        ..title = "ARTEMIS"
        ..maxSize = const Size(1069, 600)
        ..minSize = const Size(1069, 600)
        ..show();
    });
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        splashFactory: InkRipple.splashFactory,
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFFEDEDED),
          selectionColor: Color(0xff63B59D),
          selectionHandleColor: Color(0xff63B59D),
        ),
        checkboxTheme: CheckboxThemeData(
          checkColor: MaterialStateProperty.all(Colors.black),
          fillColor: MaterialStateProperty.all(Colors.white),
        ),
        useMaterial3: true,
      ),
      home: 
        WelcomeWidget(),
    );
  }
}

final buttonColors = WindowButtonColors(
    iconNormal: const Color(0xffffffff),
    mouseOver: const Color(0xFF102821),
    mouseDown: const Color(0xffffffff),
    iconMouseOver: const Color(0xffffffff),
    iconMouseDown: const Color(0xFF262623));

final closeButtonColors = WindowButtonColors(
    mouseOver: const Color(0xFF102821),
    mouseDown: const Color(0xffffffff),
    iconNormal: const Color(0xffffffff),
    iconMouseOver: const Color(0xffffffff),
    iconMouseDown: const Color(0xFF262623));

class WindowButtons extends StatelessWidget {
  const WindowButtons({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        MaximizeWindowButton(colors: buttonColors),
        CloseWindowButton(colors: closeButtonColors),
      ],
    );
  }
}

// ignore: must_be_immutable
class UnorderedList extends StatelessWidget {
  UnorderedList(this.texts, this.frame, {super.key});
  final List<String> texts;
  double frame;

  @override
  Widget build(BuildContext context) {
    var widgetList = <Widget>[];
    for (var text in texts) {
      // Add list item
      widgetList.add(UnorderedListItem(text, frame));
      // Add space between items
      widgetList.add(const SizedBox(height: 5.0));
    }

    return Column(children: widgetList);
  }
}

// ignore: must_be_immutable
class UnorderedListItem extends StatelessWidget {
  UnorderedListItem(this.text, this.frame, {super.key});
  
  final String text;
  double frame;

  @override
  Widget build(BuildContext context) {
    double fframe = frame * 0.97;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("• ",
          style: TextStyle(
            color: const Color(0xFFFFFFFF),
            fontFamily: 'Inter',
            fontSize: 24*fframe,
            fontWeight: FontWeight.w300,
            letterSpacing: 5*fframe/frame,
            height: 1.3*fframe,
          ),
        ),
        Expanded(
          child: Text(text, 
          // textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFFFFFFFF),
              fontFamily: 'Inter',
              fontSize: 22*fframe,
              fontWeight: FontWeight.w300,
              letterSpacing: 3*fframe/frame,
              height: 1.3*fframe,
            ),
          ),
        ),
      ],
    );
  }
}

class Sample { 
  
  static void AlshowDialog(context, var title,var message) {
    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF224138),
          shadowColor: const Color.fromARGB(79, 34, 65, 56),
          title: Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFFFFFFF),fontFamily: 'Inter',fontSize: 24,fontWeight: FontWeight.w500, height: 1.3,),),
          content: Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFFFFFFF),fontFamily: 'Inter',fontSize: 20,fontWeight: FontWeight.w500, height: 1.3,),),
          actions: [
            Container(
              height: 40, 
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(7.0),border: Border.all(color: const Color(0xFFFFFFFF), width: 1)),
              child: MaterialButton(
                onPressed: () {Navigator.pop(context);}, 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.0),),
                child: const Text('ОК', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFFFFFFF),fontFamily: 'Inter',fontSize: 20,fontWeight: FontWeight.w500, height: 1.3,),),
                ),
            )
          ],
        );
      }
    );
  }
}

class ShortenFileName{
  String call(String fileName, int maxLength) {
    if (fileName.length > maxLength) {
      String name = path.basenameWithoutExtension(fileName);
      String extension = path.extension(fileName);
      int charactersToShow = maxLength - 3 - extension.length;
      name = name.substring(0, charactersToShow);
      return "$name..$extension";
    }
    return fileName.split('/').last;
  }
}