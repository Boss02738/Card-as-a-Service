import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:my_app/views/widgets/brand_logo.dart';
import 'package:my_app/views/widgets/data_card.dart';
import 'package:my_app/views/widgets/gradient_header.dart';

class UserSelectionPage extends StatelessWidget {
  UserSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const GradientHeader(),
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 50.h),
                const BrandLogo(),
                SizedBox(height: 50.h),
                Expanded(
                  child: DataCard(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _selectionTile(
                          title: 'เปิดใช้งานบัญชีใหม่ NovaPay',
                          subtitle:
                              'เบอร์ใหม่ ไม่เคยมีบัญชี หรือต้องการสมัครใหม่',
                          icon: Icons.person_add_alt_1,

                          // onTap: () => Get.toNamed('/idcard_verify'), // Flow สมัครใหม่เดิม?
                          onTap: () => Get.toNamed(
                            '/idcard_verify',
                            arguments: {
                              ...Get.arguments,
                              'action': 'register',
                            },
                          ),
                        ),
                        SizedBox(height: 24.h),
                        _selectionTile(
                          title: 'เข้าสู่ระบบบัญชีเดิม',
                          subtitle:
                              'มีบัญชีอยู่แล้ว ต้องการย้ายเครื่องหรือติดตั้งแอปใหม่',
                          icon: Icons.app_registration_rounded,
                          onTap: () => Get.toNamed(
                            '/change_device',
                            arguments: {
                              ...Get.arguments,
                              'action':
                                  'change_device_flow', // ✅ กำหนดเป็นย้ายเครื่องเฉพาะเมื่อกดปุ่มนี้
                              'mobileNumber': Get.arguments['verifiedMobile'],
                            },
                          ), // ไป Flow เปลี่ยนเครื่อง
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(1.r),
          border: Border.all(color: Colors.blue.shade100),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: const Color(0xFF17337B)),
            SizedBox(width: 15.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
