// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:my_app/module/controller/pin_controller.dart';
// import '../../widgets/brand_logo.dart';

// class PinPage extends StatelessWidget {
//   const PinPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final PinController controller = Get.put(PinController());
//     // final PinController controller = Get.find<PinController>();


//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Column(
//           children: [
//             const SizedBox(height: 40),
//             const BrandLogo(),
//             const SizedBox(height: 20),
//             Obx(() {
//               final dynamic args = Get.arguments;
//               final String? action = args is Map ? args['action'] : null;

//               // เรียกใช้ตัวแปร .obs เพื่อให้ Obx ทำงานถูกต้อง
//               final bool confirmMode = controller.isConfirmMode.value;

//               String title = 'กรุณาใส่รหัสผ่าน';

//               if (action == 'change_device_flow') {
//                 title = 'กรอกรหัสผ่านเดิม';
//               } else if (action == 'forgot_password_reset') { 
//                 title = confirmMode ? 'ยืนยันรหัสผ่านใหม่' : 'ตั้งรหัสผ่านใหม่';
//               } else if (action == 'register') {
//                 title = confirmMode ? 'ยืนยันรหัสผ่าน' : 'สร้างรหัสผ่าน';
//               }
//               else {
//                 title = confirmMode ? 'ยืนยันรหัสผ่าน' : 'กรุณาใส่รหัสผ่าน';
//               }

//               return Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               );
//             }),
//             const SizedBox(height: 20),

//             // จุดวงกลมแสดงสถานะ PIN
//             Obx(
//               () => Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: List.generate(6, (index) {
//                   bool isFilled = index < controller.enteredPin.value.length;
//                   return Container(
//                     margin: const EdgeInsets.symmetric(horizontal: 8),
//                     width: 12,
//                     height: 12,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       border: Border.all(color: Colors.blueAccent),
//                       color: isFilled ? Colors.blueAccent : Colors.transparent,
//                     ),
//                   );
//                 }),
//               ),
//             ),

//             const Spacer(),

//             // Custom Keypad
//             buildKeypad(controller),
//             const SizedBox(height: 40),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildKeypad(PinController controller) {
//     return Column(
//       children: [
//         for (var row in [
//           [1, 2, 3],
//           [4, 5, 6],
//           [7, 8, 9],
//         ])
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 10),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: row
//                   .map(
//                     (n) => keypadButton(
//                       n.toString(),
//                       () => controller.addNumber(n),
//                     ),
//                   )
//                   .toList(),
//             ),
//           ),
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 10),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               // ปุ่มย้อนกลับ (แสดงเฉพาะหน้ายืนยัน)
//               Obx(
//                 () => controller.isConfirmMode.value
//                     ? TextButton(
//                         onPressed: () => controller.goBackToSetPin(),
//                         child: const Text(
//                           'ย้อนกลับ',
//                           style: TextStyle(color: Colors.black54, fontSize: 16),
//                         ),
//                       )
//                     : const SizedBox(width: 80),
//               ),

//               keypadButton('0', () => controller.addNumber(0)),

//               // ปุ่มลบ
//               IconButton(
//                 onPressed: () => controller.deleteNumber(),
//                 icon: const Icon(
//                   Icons.backspace_outlined,
//                   size: 28,
//                   color: Colors.black54,
//                 ),
//                 constraints: const BoxConstraints(minWidth: 80),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget keypadButton(String label, VoidCallback onTap) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(40),
//       child: Container(
//         width: 80,
//         height: 80,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           border: Border.all(color: Colors.grey.shade200),
//         ),
//         alignment: Alignment.center,
//         child: Text(
//           label,
//           style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
//         ),
//       ),
//     );
//   }
// }
// views/pages/Register/pin_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      // ✅ ใช้ PinLayout เป็นโครงสร้างหลักของหน้า
      body: Obx(() {
        final dynamic args = Get.arguments;
        final String? action = args is Map ? args['action'] : null;
        final bool confirmMode = controller.isConfirmMode.value;

        // ส่วนของ Logic จัดการ Title
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
          isLoading: controller.isLoading.value, // ✅ แสดง Loading Overlay อัตโนมัติ
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