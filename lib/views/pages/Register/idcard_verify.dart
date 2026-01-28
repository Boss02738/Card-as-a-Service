import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/module/controller/header_text_controller.dart';
import 'package:my_app/module/services/camera_service.dart';
import 'package:my_app/views/pages/Register/info.dart';
import 'package:my_app/views/widgets/brand_logo.dart';
import 'package:my_app/views/widgets/data_card.dart';
import 'package:my_app/views/widgets/gradient_header.dart';
import 'package:my_app/views/widgets/header_texts.dart';
import '../../widgets/arrow_fab.dart';

class IdcardVerify extends StatefulWidget {
  const IdcardVerify({super.key});

  @override
  State<IdcardVerify> createState() => _IdcardVerifyState();
}

class _IdcardVerifyState extends State<IdcardVerify> {
  final HeaderTextController headerTextController =
      Get.find<HeaderTextController>();

  File? _image; // ตัวแปรเก็บรูปที่ถ่าย
  final CameraService _cameraService = CameraService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      headerTextController.setHeaderText(
        'ยืนยันตัวตน',
        'สแกนบัตรประชาชนเพื่อยืนยันตัวตน',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const GradientHeader(),
          SafeArea(
            child: SizedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  const BrandLogo(),
                  const SizedBox(height: 30),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 22),
                    child: HeaderTexts(),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: DataCard(
                      child: SizedBox(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            // --- ส่วนกรอบบัตรประชาชนจำลอง ---
                            Container(
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.black12,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: _image != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.file(
                                        _image!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Stack(
                                      children: [
                                        Positioned(
                                          top: 15,
                                          left: 15,
                                          child: Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.black12,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          right: 15,
                                          bottom: 40,
                                          child: Container(
                                            width: 60,
                                            height: 75,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.black12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),

                            const Spacer(), // ใช้ Spacer ดันปุ่มลงข้างล่าง

                            Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  _cameraService.takePicture().then((file) {
                                    if (file != null) {
                                      setState(() {
                                        _image = file;
                                      });
                                    }
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    23,
                                    51,
                                    123,
                                  ),
                                  minimumSize: const Size(250, 45),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'เปิดกล้องเพื่อสแกน',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 40),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'ต่อไป',
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.3),
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ArrowFab(
                                  enabled: _image != null,
                                  onPressed: () {
                                    Get.to(Info());
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
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
