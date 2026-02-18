import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/module/controller/pin_login_controller.dart'; 
import 'package:my_app/views/widgets/Pin/pin_dots.dart';
import 'package:my_app/views/widgets/Pin/pin_keypad.dart';
import 'package:my_app/views/widgets/Pin/pin_layout.dart';


class PinLoginPage extends StatelessWidget {
  const PinLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PinLoginController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(
        () => PinLayout(
          title: 'กรุณาใส่รหัสผ่าน',
          isLoading: controller.isLoading.value,
          dots: PinDots(length: controller.enteredPin.value.length),
          keypad: Column(
            children: [
              PinKeypad(
                onNumber: controller.addNumber,
                onDelete: controller.deleteNumber,
              ),
              TextButton(
                onPressed: () => Get.toNamed('/face_verify'),
                child: const Text(
                  'ลืมรหัสผ่าน',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}