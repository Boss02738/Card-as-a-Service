import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/module/controller/pin_verify_controller.dart';
import 'package:my_app/views/widgets/pin/pin_layout.dart';
import 'package:my_app/views/widgets/pin/pin_dots.dart';
import 'package:my_app/views/widgets/pin/pin_keypad.dart';

class PinVerifyPage extends StatelessWidget {
  const PinVerifyPage({super.key});

  String _resolveTitle(String action) {
    switch (action) {
      case 'change_limit':
        return 'ยืนยันรหัสผ่านเพื่อเปลี่ยนวงเงิน';
      case 'view_sensitive':
        return 'ยืนยันรหัสผ่านเพื่อดูเลขบัตร';
      case 'request_physical':
        return 'ยืนยันรหัสผ่านเพื่อขอรับบัตรแข็ง';
      case 'activate_physical_flow':
        return 'กรอกรหัสผ่าน';
      default:
        return 'ยืนยันรหัสผ่านเพื่อสร้างบัตร';
    }
  }

  @override
  Widget build(BuildContext context) {
    final PinVerifyController controller = Get.put(PinVerifyController());
    final String action = controller.args['action'] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(
        () => PinLayout(
          title: _resolveTitle(action),
          isLoading: controller.isLoading.value,
          dots: PinDots(
            length: controller.enteredPin.value.length,
          ),
          keypad: PinKeypad(
            onNumber: controller.addNumber,
            onDelete: controller.deleteNumber,
          ),
        ),
      ),
    );
  }
}
