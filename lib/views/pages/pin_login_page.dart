import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/module/controller/pin_login_controller.dart'; // อย่าลืมสร้างไฟล์นี้
import 'package:my_app/views/widgets/Pin/pin_dots.dart';
import 'package:my_app/views/widgets/Pin/pin_keypad.dart';
import 'package:my_app/views/widgets/Pin/pin_layout.dart';
import 'package:my_app/views/widgets/exit_confirmation_dialog.dart';
import '../widgets/brand_logo.dart';

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


//   Widget buildKeypad(PinLoginController controller) {
//     // (ใช้ Logic เดิมจาก PinPage ได้เลยครับ)
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
//               const SizedBox(
//                 width: 80,
//               ), // เว้นที่ว่างฝั่งซ้าย (ไม่มีปุ่มย้อนกลับในหน้า Login)
//               keypadButton('0', () => controller.addNumber(0)),
//               IconButton(
//                 onPressed: () => controller.deleteNumber(),
//                 icon: const Icon(Icons.backspace_outlined, size: 28),
//                 constraints: const BoxConstraints(minWidth: 80),
//               ),
//             ],
//           ),
//         ),
//         TextButton(
//           onPressed: () {
//             Get.toNamed('/face_verify');
//           },
//           child: const Text(
//             'ลืมรหัสผ่าน',
//             style: TextStyle(color: Colors.grey, fontSize: 16),
//           ),
//         ),
//         const SizedBox(height: 20),
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
//         child: Text(label, style: const TextStyle(fontSize: 26)),
//       ),
//     );
//   }
// }
