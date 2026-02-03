import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/core/api_constants.dart';
import 'package:my_app/module/services/device_id.dart';
import 'package:my_app/module/services/secure_storage.dart';

class PinLoginController extends GetxController {
  var enteredPin = ''.obs;
  var isLoading = false.obs;

  void addNumber(int number) {
    if (enteredPin.value.length < 6) {
      enteredPin.value += number.toString();
    }
    if (enteredPin.value.length == 6) {
      // เมื่อครบ 6 หลัก ให้หน่วงเวลาเล็กน้อยเพื่อให้จุดวงกลมเต็มก่อนยิง API
      Future.delayed(const Duration(milliseconds: 200), () => loginWithPin());
    }
  }

  void deleteNumber() {
    if (enteredPin.value.isNotEmpty) {
      enteredPin.value = enteredPin.value.substring(
        0,
        enteredPin.value.length - 1,
      );
    }
  }

void _showErrorDialog() {
  Get.dialog(
    Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ===== Content =====
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 24.h),
              child: Column(
                children: [
                  // Icon !
                  Container(
                    width: 56.r,
                    height: 56.r,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF2F6BFF),
                        width: 2,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '!',
                        style: TextStyle(
                          fontSize: 36.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2F6BFF),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Title
                  Text(
                    'ขออภัย',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF222222),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Description
                  Text(
                    'คุณใส่รหัสผ่านไม่ถูกต้อง หากใส่รหัสผิดครบ 3 ครั้ง แอปพลิเคชันจะถูกล็อก\nกรณีจำรหัสไม่ได้ กด “ลืมรหัสผ่าน” เพื่อตั้งรหัสผ่านใหม่',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      height: 1.5,
                      color: const Color(0xFF333333),
                    ),
                  ),
                ],
              ),
            ),

            // Divider
            Container(
              height: 1,
              color: const Color(0xFFDADADA),
            ),

            // ===== Button =====
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 20.h),
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  height: 44.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24.r),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF2F6BFF),
                        Color(0xFF1F4ED8),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'ตกลง',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.55),
  );
}


  Future<void> loginWithPin() async {
    try {
      isLoading.value = true;

      String? mobile = await storage.read(key: 'userMobile');
      String? deviceId = await getDeviceId();

      if (mobile == null || mobile.isEmpty) {
        Get.snackbar('Error', 'ไม่พบข้อมูลผู้ใช้ กรุณาลงทะเบียนใหม่');
        return;
      }

      Map<String, dynamic> loginData = {
        "mobileNumber": mobile,
        "deviceId": deviceId,
        "pin": enteredPin.value,
      };

      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}${ApiConstants.login}"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(loginData),
      );

      if (response.statusCode == 200) {
        // --- ส่วนที่ต้องเพิ่ม/แก้ไข ---
        final responseData = jsonDecode(response.body);

        String? token = responseData['token'];

        if (token != null) {
          // บันทึก Token ลงเครื่อง
          await storage.write(key: 'accessToken', value: token);
          print("DEBUG: บันทึก Token สำเร็จ");

          Get.offAllNamed('/main'); // เข้าหน้าหลัก
        } else {
          Get.snackbar('Error', 'ไม่ได้รับรหัสยืนยันจากระบบ (Token is null)');
        }
        // ---------------------------
      } else {
       _showErrorDialog();
        enteredPin.value = ''; // ล้
      }
    } catch (e) {
      Get.snackbar('Error', 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้: $e');
      enteredPin.value = '';
    } finally {
      isLoading.value = false;
    }
  }
}
