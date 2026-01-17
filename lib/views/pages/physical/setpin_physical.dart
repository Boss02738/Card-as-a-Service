import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/module/controller/pin_verify_controller.dart'; // ใช้ Controller ตัวเดิมหรือสร้างใหม่ก็ได้
import 'package:my_app/views/widgets/brand_logo.dart';

class SetpinPhysical extends StatefulWidget {
  const SetpinPhysical({super.key});

  @override
  State<SetpinPhysical> createState() => _SetpinPhysicalState();
}

class _SetpinPhysicalState extends State<SetpinPhysical> {
  final dynamic args = Get.arguments;
  String firstPin = "";
  String secondPin = "";
  bool isConfirming = false;

  void handlePress(int n) {
    setState(() {
      if (!isConfirming) {
        if (firstPin.length < 6) firstPin += n.toString();
        if (firstPin.length == 6) {
          // เมื่อกรอกครั้งแรกครบ ให้สลับไปหน้ายืนยัน
          Future.delayed(const Duration(milliseconds: 300), () {
            setState(() => isConfirming = true);
          });
        }
      } else {
        if (secondPin.length < 6) secondPin += n.toString();
        if (secondPin.length == 6) {
          _verifyAndActivate();
        }
      }
    });
  }

  void _verifyAndActivate() {
    if (firstPin == secondPin) {
      // ✅ รหัสตรงกัน ยิง API ทันที
      final PinVerifyController controller = Get.find<PinVerifyController>();
      controller.processFinalActivate(firstPin, args);
    } else {
      // ❌ รหัสไม่ตรงกัน ให้เริ่มใหม่
      Get.snackbar("ผิดพลาด", "รหัสผ่านไม่ตรงกัน กรุณาตั้งรหัสใหม่อีกครั้ง");
      setState(() {
        firstPin = "";
        secondPin = "";
        isConfirming = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentPin = isConfirming ? secondPin : firstPin;

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
      body: Column(
        children: [
          const BrandLogo(),
          const SizedBox(height: 30),
          Text(
            isConfirming ? "ยืนยันรหัสบัตรเดบิต" : "สร้างรหัสบัตรเดบิต",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text("ระบุรหัส 6 หลักที่ต้องการเพื่อใช้กับบัตรใบนี้", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 40),
          
          // จุดแสดงผล PIN
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              width: 15, height: 15,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index < currentPin.length ? const Color(0xFF264FAD) : Colors.grey.shade300,
              ),
            )),
          ),
          
          const Spacer(),
          _buildKeypad(),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildKeypad() {
    // ใช้โครงสร้าง Keypad เหมือนหน้า PinVerifyPage เพื่อความคุ้นเคยของผู้ใช้
    return Column(
      children: [
        for (var row in [[1, 2, 3], [4, 5, 6], [7, 8, 9]])
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((n) => _keypadButton(n.toString(), () => handlePress(n))).toList(),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 80),
            _keypadButton("0", () => handlePress(0)),
            IconButton(
              icon: const Icon(Icons.backspace_outlined, size: 30),
              onPressed: () => setState(() {
                if (isConfirming && secondPin.isNotEmpty) {
                  secondPin = secondPin.substring(0, secondPin.length - 1);
                } else if (!isConfirming && firstPin.isNotEmpty) {
                  firstPin = firstPin.substring(0, firstPin.length - 1);
                }
              }),
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
      child: Container(
        width: 80, height: 80,
        alignment: Alignment.center,
        child: Text(label, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w500)),
      ),
    );
  }
}