import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/module/controller/pin_verify_controller.dart';
// ✅ Import ชุด Widget PIN สำเร็จรูป
import 'package:my_app/views/widgets/pin/pin_dots.dart';
import 'package:my_app/views/widgets/pin/pin_keypad.dart';
import 'package:my_app/views/widgets/pin/pin_layout.dart';

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

  // ดึง Controller มาเพื่อใช้ยิง API ในขั้นตอนสุดท้าย
  final PinVerifyController controller = Get.find<PinVerifyController>();

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

  void handleDelete() {
    setState(() {
      if (isConfirming) {
        if (secondPin.isNotEmpty) {
          secondPin = secondPin.substring(0, secondPin.length - 1);
        }
      } else {
        if (firstPin.isNotEmpty) {
          firstPin = firstPin.substring(0, firstPin.length - 1);
        }
      }
    });
  }

  void _verifyAndActivate() {
    if (firstPin == secondPin) {
      //  รหัสตรงกัน เรียกฟังก์ชัน activate บัตรแข็ง
      controller.processFinalActivate(firstPin, args);
    } else {
      //  รหัสไม่ตรงกัน ล้างค่าและเริ่มใหม่
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
    // เลือก PIN ที่จะแสดงตามสถานะปัจจุบัน
    String currentPin = isConfirming ? secondPin : firstPin;

    return Scaffold(
      backgroundColor: Colors.white,
      //  ใช้ PinLayout คุมโครงสร้างหน้า
      body: PinLayout(
        title: isConfirming ? "ยืนยันรหัสบัตรเดบิต" : "สร้างรหัสบัตรเดบิต",
        isLoading: controller.isLoading.value, //  จัดการหน้าจอโหลดอัตโนมัติ
        //  ใช้ PinDots แสดงวงกลมรหัสผ่าน
        dots: PinDots(
          length: currentPin.length,
        ),
        //  ใช้ PinKeypad สำหรับรับค่าตัวเลข
        keypad: PinKeypad(
          onNumber: handlePress,
          onDelete: handleDelete,
          // ปุ่มฝั่งซ้ายของเลข 0 (ถ้ากำลังยืนยัน ให้โชว์ปุ่มย้อนกลับไปแก้ไข)
          leftWidget: isConfirming 
            ? TextButton(
                onPressed: () => setState(() {
                  isConfirming = false;
                  secondPin = "";
                }),
                child: const Text(
                  "ย้อนกลับ",
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),
              )
            : const SizedBox(width: 80),
        ),
      ),
    );
  }
}