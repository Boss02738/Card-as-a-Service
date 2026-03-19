import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_app/core/service/api_constants.dart';
import 'package:my_app/core/service/api_service.dart';
import 'package:my_app/module/services/device_id.dart';
import 'package:my_app/module/services/secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; // เพิ่มบรรทัดนี้

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

  // random string generate เอาไว้ทำ nonce state
  String _generateRandomString(int length) {
    var random = Random.secure();
    var values = List<int>.generate(length, (i) => random.nextInt(256));
    return base64Url.encode(values).replaceAll('=', '');
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
  // ลบแค่ Token เพื่อป้องกันการสวมสิทธิ์ แต่เก็บเบอร์โทรไว้ใช้ Reset
  await storage.delete(key: 'accessToken');
  await storage.delete(key: 'refreshToken');
  Get.offAllNamed('/face_verify'); 
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
      print("🚀 เริ่มกระบวนการ Login...");

      String clientNonce = _generateRandomString(16);
      String clientState = _generateRandomString(16);

      String? mobile = await storage.read(key: 'userMobile');
      String? deviceId = await getDeviceId();

      final response = await _apiService.instance.post(
        ApiConstants.login,
        data: {
          "mobileNumber": mobile,
          "deviceId": deviceId,
          "pin": enteredPin.value,
          "nonce": clientNonce,
          "state": clientState,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['state'] != clientState) {
          throw Exception("Invalid state");
        }

        String idToken = responseData['idToken'];
        Map<String, dynamic> decodedToken = JwtDecoder.decode(idToken);

        if (decodedToken['nonce'] != clientNonce) {
          throw Exception("Invalid nonce");
        }

        await storage.write(key: 'accessToken', value: responseData['token']);
        await storage.write(
          key: 'refreshToken',
          value: responseData['refreshToken'],
        );
        Get.offAllNamed('/main');
      }
    } on DioException catch (e) {
      //  1. ดึง Error จริงมา Print ลง Console เพื่อให้ Dev ตรวจสอบได้ง่าย
      final responseData = e.response?.data;
      final statusCode = e.response?.statusCode;
      final serverMsg = responseData?['message']?.toString() ?? "";
      
      print("📦 Server Response Data: $responseData");
      print("🔢 Status Code: $statusCode");

      // เคลียร์ PIN ทันที
      enteredPin.value = '';

      //  2. ใช้ Logic ตัดสินใจเลือกเปิด Dialog ที่คุณมีอยู่แล้ว
      // ถ้า statusCode เป็น 401 และมีคำว่า 'ระงับ' หรือ 'ล็อก' ให้เปิด LockedDialog
      if (statusCode == 401 && (serverMsg.contains('ระงับ') || serverMsg.contains('ล็อก'))) {
        _showLockedDialog();
      } else {
        // กรณีอื่นๆ เช่น ใส่ผิดครั้งที่ 1 หรือ 2 ให้เปิด ErrorDialog ปกติ
        _showErrorDialog();
      }

    } catch (e) {
      print("❌ Local System Error: $e");
      enteredPin.value = '';
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
