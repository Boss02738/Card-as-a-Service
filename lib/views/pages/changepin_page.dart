import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/module/controller/changePin_controller.dart';
import 'package:my_app/views/widgets/brand_logo.dart';

class ChangePinPage extends StatelessWidget {
  const ChangePinPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ChangePinController controller = Get.put(ChangePinController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const BrandLogo(),
              const SizedBox(height: 40),
              //  หัวข้อเปลี่ยนตาม Step
              Obx(() => Text(
                controller.currentStep.value == ChangePinStep.current
                    ? 'กรอกรหัสปัจจุบัน'
                    : controller.currentStep.value == ChangePinStep.newPin
                        ? 'รหัสผ่านใหม่'
                        : 'ยืนยันรหัสผ่าน',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              )),
              const SizedBox(height: 30),
              //  จุดวงกลมแสดง PIN
              Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  bool isFilled = index < controller.enteredPin.value.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 14, height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF264FAD), width: 2),
                      color: isFilled ? const Color(0xFF264FAD) : Colors.transparent,
                    ),
                  );
                }),
              )),
              const Spacer(),
              _buildKeypad(controller),
              const SizedBox(height: 50),
            ],
          ),
          // Loading Overlay
          Obx(() => controller.isLoading.value 
            ? Container(color: Colors.black26, child: const Center(child: CircularProgressIndicator())) 
            : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildKeypad(ChangePinController controller) {
    // ใช้ Keypad เดียวกับหน้า PinLoginPage
    return Column(
      children: [
        for (var row in [[1, 2, 3], [4, 5, 6], [7, 8, 9]])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((n) => _keypadButton(n.toString(), () => controller.addNumber(n))).toList(),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 80),
            _keypadButton('0', () => controller.addNumber(0)),
            IconButton(
              onPressed: () => controller.deleteNumber(),
              icon: const Icon(Icons.backspace_outlined, size: 28),
              constraints: const BoxConstraints(minWidth: 80),
            ),
          ],
        ),
      ],
    );
  }

  Widget _keypadButton(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Container(width: 80, height: 80, alignment: Alignment.center,
        child: Text(label, style: const TextStyle(fontSize: 26))),
    );
  }
}