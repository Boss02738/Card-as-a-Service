import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/module/services/secure_storage.dart';
import 'package:my_app/views/widgets/gradient_header.dart';

class Welcome_Page extends StatefulWidget {
  const Welcome_Page({super.key});

  @override
  State<Welcome_Page> createState() => _Welcome_PageState();
}

class _Welcome_PageState extends State<Welcome_Page> {
  @override
  void initState() {
    super.initState();
    // เมื่อหน้าจอโหลดเสร็จ ให้เริ่มเช็คสถานะทันที
    _checkRegistrationStatus();
  }

  Future<void> _checkRegistrationStatus() async {
    // หน่วงเวลาโชว์โลโก้สัก 2 วินาทีเพื่อให้ดูเหมือน Splash Screen จริงๆ
    await Future.delayed(const Duration(seconds: 2));

    // 1. อ่านค่า Flag จาก Secure Storage
    String? isRegistered = await storage.read(key: 'isRegistered');
    // 2. ตรวจสอบเงื่อนไข
    if (isRegistered == 'true') {
      // กรณีเคยสมัครแล้ว -> ส่งไปหน้าใส่ PIN (Login)
      // เปลี่ยนเป็นชื่อ Route หรือชื่อ Class หน้า Login ของคุณ
      Get.offAllNamed('/login-pin');
    } else {
      // กรณีผู้ใช้ใหม่ -> ส่งไปหน้ากรอกเบอร์โทร (Register)
      // เปลี่ยนเป็นชื่อ Route หรือชื่อ Class หน้ากรอกเบอร์ของคุณ
      Get.offAllNamed('/enter-phone');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const GradientHeader(),
          Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: Image.asset('assets/images/novapay_logo.png'),
            ),
          ),
          // เพิ่ม Loading เล็กๆ ด้านล่างเพื่อให้ผู้ใช้รู้ว่าระบบกำลังทำงาน
          const Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
