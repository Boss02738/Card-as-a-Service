import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_prevent_screenshot/disablescreenshot.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:my_app/views/pages/enter_phone_page.dart';
import 'package:my_app/views/pages/face_verify.dart';
import 'package:my_app/views/pages/idcard_verify.dart';
import 'package:my_app/views/pages/info.dart';
import 'package:my_app/views/pages/home.dart';
import 'package:my_app/views/pages/welcome_page.dart';
import 'package:my_app/views/pages/confirm_otp.dart';
void main() {
  runApp(const NovaPayApp());
}

class NovaPayApp extends StatefulWidget {  
  const NovaPayApp({super.key});

  @override
  State<NovaPayApp> createState() => _NovaPayAppState();
}

class _NovaPayAppState extends State<NovaPayApp> {
final _flutterPreventScreenshot = FlutterPreventScreenshot.instance;

turnoffScreenshot() async {
  final result = await _flutterPreventScreenshot.screenshotOff();
  if (kDebugMode) {
    print(result);
  }
}

@override
void initState() {
  turnoffScreenshot();
  super.initState();
}

@override
void dispose() {
  _flutterPreventScreenshot.screenshotOn();

  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: EnterPhonePage(),
    );
  }
}
