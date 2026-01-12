import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/views/widgets/gradient_header.dart';

class SuccessPaga extends StatelessWidget {
  const SuccessPaga({super.key});

  @override
  Widget build(BuildContext context) {
    final String title = Get.arguments['title'];
    final String subtitle = Get.arguments['subtitle'];
    // final String title = args != null && args['title'] != null
        // ? args['title']
    //     : 'ทำรายการสำเร็จ';

    // final String subtitle = args != null && args['subtitle'] != null
    //     ? args['subtitle']
    //     : 'สามารถเริ่มใช้งานได้ทันที';
    return Scaffold(
      body: Stack(
        children: [
          const GradientHeader(),
          Center(
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),
                  Container(
                    width: 140,
                    height: 140,
                    decoration: const BoxDecoration(
                      color: Color(0xFF27AE60),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 90,
                    ),
                  ),

                  const SizedBox(height: 30),

                   Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                   Text(
                    subtitle,
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),

                  const Spacer(flex: 2),

                  // ปุ่มตกลง
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 40,
                    ),
                    child: SizedBox(
                      width: 180,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.offAllNamed('/home');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1D46B9),
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(), // ปุ่มทรงแคปซูล
                          elevation: 5,
                        ),
                        child: const Text(
                          'ตกลง',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
