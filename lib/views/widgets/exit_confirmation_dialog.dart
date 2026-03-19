import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ExitConfirmationDialog {
  static Future<bool> show() async {
    return await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('ออกจากแอปพลิเคชัน?', 
          style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('คุณต้องการออกจากแอปใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => SystemNavigator.pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 55, 51, 119),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    ) ?? false;
  }
}

class BackButtonInterceptor extends StatelessWidget {
  final Widget child;
  const BackButtonInterceptor({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,  
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        // เรียกใช้ Static Method เพื่อโชว์ Dialog
        await ExitConfirmationDialog.show();
      },
      child: child,
    );
  }
}