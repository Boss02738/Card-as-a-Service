import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_app/core/service/api_constants.dart';
import 'package:my_app/core/service/api_service.dart';
import 'package:my_app/module/services/device_id.dart';
import 'package:my_app/module/services/secure_storage.dart';

class PinLoginController extends GetxController {
  var enteredPin = ''.obs;
  var isLoading = false.obs;
  final ApiService _apiService = ApiService();

  void addNumber(int number) {
    if (isLoading.value) return;

    if (enteredPin.value.length < 6) {
      enteredPin.value += number.toString();
    }

    if (enteredPin.value.length == 6 && !isLoading.value) {
      // เมื่อครบ 6 หลัก ให้หน่วงเวลาเล็กน้อยเพื่อให้จุดวงกลมเต็มก่อนยิง API
      Future.delayed(const Duration(milliseconds: 200), () => loginWithPin());
    }
  }

  void deleteNumber() {
    if (enteredPin.value.isNotEmpty && !isLoading.value) {
      enteredPin.value = enteredPin.value.substring(
        0,
        enteredPin.value.length - 1,
      );
    }
  }

  // --- Dialog กรณีใส่รหัสผิดปกติ (ยังไม่ครบ 3 ครั้ง) ---
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
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 24.h),
                child: Column(
                  children: [
                    _buildIcon('!'),
                    SizedBox(height: 16.h),
                    Text(
                      'ขออภัย',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'คุณใส่รหัสผ่านไม่ถูกต้อง หากใส่รหัสผิดครบ \n 3 ครั้ง แอปพลิเคชันจะถูกล็อก ต้องทำการรีเซ็ตรหัสผ่าน ',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14.sp, height: 1.5),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              _buildDialogButton('ตกลง', () => Get.back()),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // --- Dialog กรณีบัญชีถูกล็อก (ผิดครบ 3 ครั้ง) ---
  void _showLockedDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 24.h),
                child: Column(
                  children: [
                    _buildIcon('!', color: Colors.red),
                    SizedBox(height: 16.h),
                    Text(
                      'บัญชีถูกระงับชั่วคราว',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'คุณกรอกรหัสผิดเกินกำหนด เพื่อความปลอดภัย ระบบได้ทำการล็อกบัญชีของคุณ กรุณาตั้งรหัสผ่านใหม่',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14.sp, height: 1.5),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              _buildDialogButton('ตั้งรหัสผ่านใหม่', () async {
                await storage.deleteAll(); // ล้าง Token เก่า
                Get.offAllNamed('/face_verify'); // พาไปเริ่ม Reset PIN
              }),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> loginWithPin() async {
    if (isLoading.value) return;
    try {
      isLoading.value = true;
      String? mobile = await storage.read(key: 'userMobile');
      String? deviceId = await getDeviceId();

      if (mobile == null || mobile.isEmpty) {
        Get.snackbar('Error', 'ไม่พบข้อมูลผู้ใช้');
        isLoading.value = false;
        return;
      }

      final response = await _apiService.instance.post(
        ApiConstants.login,
        data: {
          "mobileNumber": mobile,
          "deviceId": deviceId,
          "pin": enteredPin.value,
 },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['token'] != null) {
          await storage.write(key: 'accessToken', value: responseData['token']);
          await storage.write(
            key: 'refreshToken',
            value: responseData['refreshToken'],
          );
          Get.offAllNamed('/main');
        }
      }
    } catch (e) {
      enteredPin.value = ''; // ล้างค่า PIN ทันทีเพื่อป้องกัน Loop

      if (e is DioException) {
        final responseData = e.response?.data;
        //  ตรวจสอบสถานะ Account Locked จาก Backend
        if (e.response?.statusCode == 401 &&
            responseData?['message'] ==
                'บัญชีถูกระงับชั่วคราวเนื่องจากใส่รหัสผิดเกิน 3 ครั้ง กรุณากด \'ลืมรหัสผ่าน\' เพื่อตั้งค่าใหม่') {
          _showLockedDialog();
        } else {
          _showErrorDialog();
        }
      } else {
        Get.snackbar('Error', 'เกิดข้อผิดพลาดในการเชื่อมต่อ');
      }
    } finally {
      isLoading.value = false;
    }
  }

  // --- Helper Widgets สำหรับ Dialog ---
  Widget _buildIcon(String char, {Color color = const Color(0xFF2F6BFF)}) {
    return Container(
      width: 56.r,
      height: 56.r,
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          char,
          style: TextStyle(
            fontSize: 36.sp,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildDialogButton(String text, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 20.h),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            gradient: const LinearGradient(
              colors: [Color(0xFF2F6BFF), Color(0xFF1F4ED8)],
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
