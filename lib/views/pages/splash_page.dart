import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/module/services/secure_storage.dart'; // ไฟล์ที่คุณประกาศ storage ไว้

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    // หน่วงเวลาโชว์โลโก้แป๊บหนึ่ง
    await Future.delayed(const Duration(seconds: 2));

    // อ่านค่าจาก Storage
    String? isRegistered = await storage.read(key: 'isRegistered');
    print(
      "Debug: isRegistered flag is $isRegistered",
    ); // เพิ่ม print เพื่อดูสถานะใน Console
    if (isRegistered == 'true') {
      // ถ้าสมัครแล้ว ส่งไปหน้าใส่ PIN (Login)
      Get.offAllNamed('/login-pin');
    } else {
      // ถ้ายังไม่สมัคร ส่งไปหน้า Welcome หรือหน้ากรอกเบอร์
      Get.offAllNamed('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // หรือโชว์โลโก้ NovaPay ของคุณ
      ),
    );
  }
}
