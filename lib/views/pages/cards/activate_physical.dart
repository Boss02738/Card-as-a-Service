import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ActivatePhysical extends StatelessWidget {
  const ActivatePhysical({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'เปิดใช้งานบัตร',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF264FAD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
    );
  }
}
