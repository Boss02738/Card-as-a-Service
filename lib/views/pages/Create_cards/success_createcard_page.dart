import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/views/widgets/gradient_header.dart';

class SuccessCreatecardPaga extends StatelessWidget {
  const SuccessCreatecardPaga({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ใช้ Stack เพื่อวางเนื้อหาทับบนพื้นหลัง Gradient
      body: Stack(
        children: [
          // 1. พื้นหลัง (ใช้ Widget GradientHeader ของคุณ)
          const GradientHeader(),

          // 2. เนื้อหาหลัก
          Center(
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),
            
                  // วงกลมสีเขียวและเครื่องหมายถูก
                  Container(
                    width: 140,
                    height: 140,
                    decoration: const BoxDecoration(
                      color: Color(0xFF27AE60), // สีเขียว Success
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 90,
                    ),
                  ),
            
                  const SizedBox(height: 30),
            
                  // ข้อความแจ้งสถานะ
                  const Text(
                    'ทำรายการสมัครบัตรเรียบร้อยแล้ว',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'สามารถเริ่มใช้งานได้ทันที',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
            
                  const Spacer(flex: 2),
            
                  // ปุ่มตกลงด้านล่าง
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                    child: SizedBox(
                      width: 180,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          // กลับไปหน้า Home และล้าง Stack ทั้งหมด
                          Get.offAllNamed('/home');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1D46B9), // สีน้ำเงินเข้ม
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(), // ปุ่มทรงแคปซูล
                          elevation: 5,
                        ),
                        child: const Text(
                          'ตกลง',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}