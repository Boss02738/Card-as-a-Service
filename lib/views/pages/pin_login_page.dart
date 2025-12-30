import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/module/controller/pin_login_controller.dart'; // อย่าลืมสร้างไฟล์นี้
import '../widgets/brand_logo.dart';

class PinLoginPage extends StatelessWidget {
  const PinLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // เรียกใช้ Login Controller แทน Register Controller
    final PinLoginController controller = Get.put(PinLoginController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 60),
                const BrandLogo(),
                const SizedBox(height: 40),
                const Text(
                  'กรุณาใส่รหัสผ่าน',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                
                // จุดวงกลมแสดงสถานะ PIN
                Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (index) {
                    bool isFilled = index < controller.enteredPin.value.length;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blueAccent, width: 2),
                        color: isFilled ? Colors.blueAccent : Colors.transparent,
                      ),
                    );
                  }),
                )),
                
                const Spacer(),
                
                // Keypad สำหรับ Login
                buildKeypad(controller),
                const SizedBox(height: 40),
              ],
            ),
          ),
          
          // หน้าจอ Loading ระหว่างเช็ครหัส
          Obx(() => controller.isLoading.value 
            ? Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              ) 
            : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget buildKeypad(PinLoginController controller) {
    // (ใช้ Logic เดิมจาก PinPage ได้เลยครับ)
    return Column(
      children: [
        for (var row in [[1, 2, 3], [4, 5, 6], [7, 8, 9]])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((n) => keypadButton(n.toString(), () => controller.addNumber(n))).toList(),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 80), // เว้นที่ว่างฝั่งซ้าย (ไม่มีปุ่มย้อนกลับในหน้า Login)
              keypadButton('0', () => controller.addNumber(0)),
              IconButton(
                onPressed: () => controller.deleteNumber(),
                icon: const Icon(Icons.backspace_outlined, size: 28),
                constraints: const BoxConstraints(minWidth: 80),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget keypadButton(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 80, height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade200),
        ),
        alignment: Alignment.center,
        child: Text(label, style: const TextStyle(fontSize: 26)),
      ),
    );
  }
}