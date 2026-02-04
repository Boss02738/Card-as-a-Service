// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:my_app/module/controller/changePin_controller.dart';
// import 'package:my_app/views/widgets/brand_logo.dart';

// class ChangePinPage extends StatelessWidget {
//   const ChangePinPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final ChangePinController controller = Get.put(ChangePinController());

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
//           onPressed: () => Get.back(),
//         ),
//       ),
//       body: Stack(
//         children: [
//           Column(
//             children: [
//               const BrandLogo(),
//               const SizedBox(height: 40),
//               //  หัวข้อเปลี่ยนตาม Step
//               Obx(() => Text(
//                 controller.currentStep.value == ChangePinStep.current
//                     ? 'กรอกรหัสปัจจุบัน'
//                     : controller.currentStep.value == ChangePinStep.newPin
//                         ? 'รหัสผ่านใหม่'
//                         : 'ยืนยันรหัสผ่าน',
//                 style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//               )),
//               const SizedBox(height: 30),
//               //  จุดวงกลมแสดง PIN
//               Obx(() => Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: List.generate(6, (index) {
//                   bool isFilled = index < controller.enteredPin.value.length;
//                   return Container(
//                     margin: const EdgeInsets.symmetric(horizontal: 10),
//                     width: 14, height: 14,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       border: Border.all(color: const Color(0xFF264FAD), width: 2),
//                       color: isFilled ? const Color(0xFF264FAD) : Colors.transparent,
//                     ),
//                   );
//                 }),
//               )),
//               const Spacer(),
//               _buildKeypad(controller),
//               const SizedBox(height: 50),
//             ],
//           ),
//           // Loading Overlay
//           Obx(() => controller.isLoading.value 
//             ? Container(color: Colors.black26, child: const Center(child: CircularProgressIndicator())) 
//             : const SizedBox.shrink()),
//         ],
//       ),
//     );
//   }

// }// views/pages/change_pin_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/module/controller/changePin_controller.dart';
import 'package:my_app/views/widgets/pin/pin_dots.dart';
import 'package:my_app/views/widgets/pin/pin_keypad.dart';
import 'package:my_app/views/widgets/pin/pin_layout.dart';

class ChangePinPage extends StatelessWidget {
  const ChangePinPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ChangePinController controller = Get.put(ChangePinController());

    return Scaffold(
      backgroundColor: Colors.white,
      // ✅ ใช้ PinLayout เป็นโครงสร้างหลักของหน้า
      body: Obx(() {
        // กำหนดหัวข้อตามขั้นตอนปัจจุบัน
        String title = 'กรอกรหัสปัจจุบัน';
        if (controller.currentStep.value == ChangePinStep.newPin) {
          title = 'รหัสผ่านใหม่';
        } else if (controller.currentStep.value == ChangePinStep.confirm) {
          title = 'ยืนยันรหัสผ่านใหม่';
        }

        return PinLayout(
          title: title,
          isLoading: controller.isLoading.value,
          // ✅ แสดงจุดรหัสผ่านด้วย PinDots
          dots: PinDots(
            length: controller.enteredPin.value.length,
          ),
          // ✅ แผงปุ่มกดด้วย PinKeypad
          keypad: PinKeypad(
            onNumber: controller.addNumber,
            onDelete: controller.deleteNumber,
            // เพิ่มปุ่มย้อนกลับที่ฝั่งซ้ายของเลข 0
            leftWidget: TextButton(
              onPressed: controller.handleBackStep,
              child: const Text(
                'ย้อนกลับ',
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
            ),
          ),
        );
      }),
    );
  }
}