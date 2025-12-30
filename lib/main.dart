import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_prevent_screenshot/disablescreenshot.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:my_app/views/pages/enter_phone_page.dart';
import 'package:my_app/views/pages/face_verify.dart';
import 'package:my_app/views/pages/home_page.dart';
import 'package:my_app/views/pages/idcard_verify.dart';
import 'package:my_app/views/pages/info.dart';
import 'package:my_app/views/pages/success_page.dart';
import 'package:my_app/views/pages/pin_login_page.dart';
import 'package:my_app/views/pages/welcome_page.dart';
import 'package:my_app/views/pages/confirm_otp.dart';
import 'package:my_app/views/pages/splash_page.dart';


void main() {
  // ต้องมีบรรทัดนี้เพื่อให้ Plugin ต่างๆ (เช่น Secure Storage) ทำงานได้ถูกต้อง
  WidgetsFlutterBinding.ensureInitialized(); 
  runApp(const NovaPayApp());
}

class NovaPayApp extends StatefulWidget {
  const NovaPayApp({super.key});
  @override
  State<NovaPayApp> createState() => _NovaPayAppState();
}

class _NovaPayAppState extends State<NovaPayApp> {
  // ย้าย Logic การกัน Screenshot มาไว้ที่นี่ตามเดิม
  final _flutterPreventScreenshot = FlutterPreventScreenshot.instance;

  @override
  void initState() {
    super.initState();
    _flutterPreventScreenshot.screenshotOff();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      // เปลี่ยนหน้าแรกให้เป็นหน้า Welcome_Page เพื่อเช็คสถานะจาก Storage
      initialRoute: '/home', 
      getPages: [
        GetPage(name: '/', page: () => const Welcome_Page()),
        GetPage(name: '/enter-phone', page: () => const EnterPhonePage()),
        GetPage(name: '/success', page: () => const SuccessPage()),
        GetPage(name: '/login-pin', page: () => const PinLoginPage()),
        GetPage(name: '/confirm-otp', page: () => const Confirm_otp()),
        GetPage(name: "/home", page: () => const HomePage())
      ],
    );
  }
}