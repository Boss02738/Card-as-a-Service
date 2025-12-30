import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/core/api_constants.dart';
import 'package:my_app/module/services/device_id.dart';
import 'package:my_app/module/services/secure_storage.dart';
import 'package:my_app/core/api_constants.dart';

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

  Future<void> loginWithPin() async {
    try {
      isLoading.value = true;

      // 1. ดึงข้อมูลที่เคยบันทึกไว้ในเครื่อง
      String? mobile = await storage.read(key: 'userMobile');
      String? deviceId = await getDeviceId();
      print("DEBUG: Logging in with Mobile: $mobile, DeviceId: $deviceId");

      if (mobile == null || mobile.isEmpty) {
      Get.snackbar('Error', 'ไม่พบข้อมูลผู้ใช้ในเครื่องนี้ กรุณาลงทะเบียนใหม่');
      return;
    }
      // 2. เตรียมข้อมูลส่งไปที่ API Login
      Map<String, dynamic> loginData = {
        "mobileNumber": mobile,
        "deviceId": deviceId,
        "password": enteredPin.value,
      };

      // 3. ยิง API (สมมติว่าใช้ Endpoint login ที่คุณเตรียมไว้)
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}${ApiConstants.login}"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(loginData),
      );

      if (response.statusCode == 200) {
        Get.offAllNamed('/home'); // เข้าหน้าหลักสำเร็จ
      } else {
        Get.snackbar('ผิดพลาด', 'รหัสผ่านไม่ถูกต้อง');
        enteredPin.value = ''; // ล้างค่าเพื่อให้กรอกใหม่
      }
    } catch (e) {
      Get.snackbar('Error', 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้: $e');
      enteredPin.value = '';
    } finally {
      isLoading.value = false;
    }
  }
}
