import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/module/controller/phonenumber_controller.dart';
import 'package:my_app/module/services/secure_storage.dart';
import 'package:my_app/views/widgets/data_card.dart';
import 'package:my_app/views/widgets/gradient_header.dart';
import 'package:my_app/module/services/camera_service.dart';
import '../../widgets/arrow_fab.dart';

class FaceVerify extends StatefulWidget {
  const FaceVerify({super.key});

  @override
  State<FaceVerify> createState() => _FaceVerifyState();
}

class _FaceVerifyState extends State<FaceVerify> {
  final CameraService _cameraService = CameraService();
  File? _image;

  // ✅ ลบบรรทัด phoneCtrl ออกแล้ว เพื่อไม่ให้แอปเด้งตอนลืมรหัสผ่าน

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const GradientHeader(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                // --- ส่วนหัวข้อ ---
                const Center(
                  child: Text(
                    'กรุณาวางใบหน้าในกรอบที่กำหนด',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // --- ส่วนกรอบใบหน้า (Overlay) ---
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _image != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _image!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              )
                            : Image.asset(
                                'assets/images/face_verify.png',
                                fit: BoxFit.contain,
                              ),
                      ],
                    ),
                  ),
                ),

                DataCard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 20),
                      // ป้ายเตือนมิจฉาชีพ
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'ระวัง!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'มิจฉาชีพหลอกให้สแกนใบหน้าเพื่อใช้งาน NovaPay',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      // ปุ่มเปิดกล้อง
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            _cameraService.takePicture().then((file) {
                              if (file != null) {
                                setState(() => _image = file);
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF17337B),
                            minimumSize: const Size(280, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'เปิดกล้องเพื่อสแกน',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // ปุ่มต่อไป
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'ต่อไป',
                            style: TextStyle(
                              color: _image != null
                                  ? Colors.black
                                  : Colors.black.withOpacity(0.3),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 10),
                          ArrowFab(
                            enabled: _image != null,
                            onPressed: () async {
                              final args = Get.arguments;
                              final Map<String, dynamic> currentArgs =
                                  (args is Map)
                                      ? Map<String, dynamic>.from(args)
                                      : {};

                              final String action =
                                  currentArgs['action'] ?? 'forgot_password_reset';
                              
                              String? mobile; // สร้างตัวแปรมารอรับค่า

                              // ✅ Logic ที่ถูกต้องและปลอดภัย
                              if (action == 'register') {
                                // กรณีสมัครสมาชิก: ดึงจาก Controller (เช็คก่อนว่ามีไหม)
                                if (Get.isRegistered<PhonenumberController>()) {
                                  mobile = Get.find<PhonenumberController>().phoneNumber.value;
                                }
                              } else if (action == 'change_device_flow') {
                                // กรณีย้ายเครื่อง: ดึงจาก Arguments
                                mobile = currentArgs['verifiedMobile'] ?? currentArgs['mobileNumber'];
                              } else {
                                // กรณีลืมรหัสผ่าน: ดึงจาก Storage
                                mobile = await storage.read(key: 'userMobile');
                              }

                              if (mobile == null || mobile.isEmpty) {
                                Get.snackbar(
                                  'ผิดพลาด',
                                  'ไม่พบข้อมูลเบอร์โทรศัพท์',
                                );
                                return;
                              }

                              Get.toNamed(
                                '/pin_page',
                                arguments: {
                                  ...currentArgs,
                                  'action': action,
                                  'mobileNumber': mobile,
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}