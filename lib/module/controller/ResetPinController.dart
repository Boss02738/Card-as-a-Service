import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/core/api_constants.dart';
import 'package:my_app/module/services/device_id.dart';
import 'package:my_app/module/services/secure_storage.dart';

class ResetPinController extends GetxController {
  var enteredPin = ''.obs;
  var firstPin = ''.obs;
  var isConfirmMode = false.obs;
  var isLoading = false.obs;

  void addNumber(int number) {
    if (enteredPin.value.length < 6) {
      enteredPin.value += number.toString();
    }
    if (enteredPin.value.length == 6) {
      Future.delayed(const Duration(milliseconds: 200), () => handlePinComplete());
    }
  }

  void handlePinComplete() {
    if (!isConfirmMode.value) {
      // รอบแรก: เก็บ PIN ใหม่ไว้
      firstPin.value = enteredPin.value;
      enteredPin.value = '';
      isConfirmMode.value = true;
    } else {
      // รอบสอง: ตรวจสอบว่าตรงกันไหม
      if (enteredPin.value == firstPin.value) {
        processResetPassword();
      } else {
        Get.snackbar('ผิดพลาด', 'รหัสผ่านไม่ตรงกัน กรุณาลองใหม่');
        enteredPin.value = '';
      }
    }
  }

  Future<void> processResetPassword() async {
    try {
      isLoading.value = true;
      String? mobile = await storage.read(key: 'userMobile'); // ดึงเบอร์จากเครื่อง
      String? deviceId = await getDeviceId();

      // 📦 เตรียมข้อมูลตาม Postman
      Map<String, dynamic> body = {
        "mobileNumber": mobile,
        "newPin": firstPin.value,
        "deviceId": deviceId,
      };

      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}${ApiConstants.forgetPassword}"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // ✅ สำเร็จ กลับไปหน้า Login เพื่อให้เข้าสู่ระบบใหม่ด้วยรหัสใหม่
        Get.offAllNamed('/pin_login');
        Get.snackbar('สำเร็จ', 'ตั้งรหัสผ่านใหม่เรียบร้อยแล้ว กรุณาเข้าสู่ระบบอีกครั้ง');
      } else {
        final error = jsonDecode(utf8.decode(response.bodyBytes));
        Get.snackbar('ผิดพลาด', error['message'] ?? 'ไม่สามารถรีเซ็ตรหัสผ่านได้');
        resetFlow();
      }
    } catch (e) {
      Get.snackbar('Error', 'เกิดข้อผิดพลาดในการเชื่อมต่อ');
    } finally {
      isLoading.value = false;
    }
  }

  void resetFlow() {
    enteredPin.value = '';
    firstPin.value = '';
    isConfirmMode.value = false;
  }
}