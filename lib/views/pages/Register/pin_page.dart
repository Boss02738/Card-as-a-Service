import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:my_app/module/controller/phonenumber_controller.dart';
import 'package:my_app/module/controller/pin_controller.dart';
import 'package:my_app/views/widgets/pin/pin_dots.dart';
import 'package:my_app/views/widgets/pin/pin_keypad.dart';
import 'package:my_app/views/widgets/pin/pin_layout.dart';

class PinPage extends StatelessWidget {
  const PinPage({super.key});

  @override
  Widget build(BuildContext context) {
    final PinController controller = Get.put(PinController());
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        final dynamic args = Get.arguments;
        final String? action = args is Map ? args['action'] : null;
        final bool confirmMode = controller.isConfirmMode.value;
        String title = 'กรุณาใส่รหัสผ่าน';
        if (action == 'change_device_flow') {
          title = 'กรอกรหัสผ่านเดิม';
        } else if (action == 'forgot_password_reset') { 
          title = confirmMode ? 'ยืนยันรหัสผ่านใหม่' : 'ตั้งรหัสผ่านใหม่';
        } else if (action == 'register') {
          title = confirmMode ? 'ยืนยันรหัสผ่าน' : 'สร้างรหัสผ่าน';
        } else {
          title = confirmMode ? 'ยืนยันรหัสผ่าน' : 'กรุณาใส่รหัสผ่าน';
        }

        return PinLayout(
          title: title,
          isLoading: controller.isLoading.value,
          // ✅ แสดงจุดรหัสผ่าน
          dots: PinDots(
            length: controller.enteredPin.value.length,
          ),
          // ✅ แผงปุ่มกดตัวเลข
          keypad: PinKeypad(
            onNumber: controller.addNumber,
            onDelete: controller.deleteNumber,
            // ✅ แสดงปุ่ม "ย้อนกลับ" เฉพาะตอนกดยืนยัน (Confirm Mode)
            leftWidget: controller.isConfirmMode.value
                ? TextButton(
                    onPressed: () => controller.goBackToSetPin(),
                    child: const Text(
                      'ย้อนกลับ',
                      style: TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                  )
                : const SizedBox(width: 80), // เว้นที่ว่างไว้เพื่อให้เลข 0 อยู่ตรงกลางเสมอ
          ),
        );
      }),
    );
  }
}