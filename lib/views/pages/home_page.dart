import 'package:flutter/material.dart';
import 'package:my_app/views/widgets/brand_logo.dart';
import 'package:my_app/views/widgets/gradient_header.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GradientHeader(),
          SafeArea(
            child: SizedBox(
              child: SizedBox(
                child: Column(
                  children: [
                    SizedBox(height: 30),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Center(child: BrandLogo()),
                        Positioned(
                          left:
                              15, // ใช้ left แทน Padding เพื่อกำหนดระยะห่างจากขอบซ้าย
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 90, 82, 82).withOpacity(
                                0.3,
                              ), // พื้นหลังวงกลมแบบโปร่งแสง
                              shape: BoxShape.circle,
                            ),
                            child: const CircleAvatar(
                              radius: 20, // ปรับขนาดวงกลม
                              backgroundColor: Color.fromARGB(124, 241, 240, 240),
                              child: Icon(
                                Icons.person_2,
                                color: Color(
                                  0xFF264FAD,
                                ), 
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
