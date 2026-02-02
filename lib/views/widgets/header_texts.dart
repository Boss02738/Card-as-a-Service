import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_app/module/controller/header_text_controller.dart';

class HeaderTexts extends StatelessWidget {
  const HeaderTexts({super.key});

  @override
  Widget build(BuildContext context) {
    // เรียกใช้ Controller ที่ถูกสร้างไว้
    final HeaderTextController controller = Get.find<HeaderTextController>();

    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controller.title.value, // ดึงค่าจาก Controller
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
       SizedBox(height: 6.h),
        Text(
          controller.subtitle.value, // ดึงค่าจาก Controller
          style: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 16.sp),
        ),
       SizedBox(height: 20.h),
      ],
    ));
  }
}
