import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/module/controller/pin_controller.dart';
import '../../widgets/brand_logo.dart';

class PinPage extends StatelessWidget {
  const PinPage({super.key});

  @override
  Widget build(BuildContext context) {
    final PinController controller = Get.put(PinController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            const BrandLogo(),
            const SizedBox(height: 20),
            
            // หัวข้อเปลี่ยนตาม Mode
            Obx(() => Text(
              controller.isConfirmMode.value ? 'ยืนยันรหัสผ่าน' : 'กรุณาใส่รหัสผ่าน',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            )),
            const SizedBox(height: 20),
            
            // จุดวงกลมแสดงสถานะ PIN
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) {
                bool isFilled = index < controller.enteredPin.value.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blueAccent),
                    color: isFilled ? Colors.blueAccent : Colors.transparent,
                  ),
                );
              }),
            )),
            
            const Spacer(),
            
            // Custom Keypad
            buildKeypad(controller),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget buildKeypad(PinController controller) {
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
              // ปุ่มย้อนกลับ (แสดงเฉพาะหน้ายืนยัน)
              Obx(() => controller.isConfirmMode.value 
                ? TextButton(
                    onPressed: () => controller.goBackToSetPin(),
                    child: const Text('ย้อนกลับ', style: TextStyle(color: Colors.black54, fontSize: 16)),
                  )
                : const SizedBox(width: 80)),
              
              keypadButton('0', () => controller.addNumber(0)),
              
              // ปุ่มลบ
              IconButton(
                onPressed: () => controller.deleteNumber(),
                icon: const Icon(Icons.backspace_outlined, size: 28, color: Colors.black54),
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
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade200),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}