import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/core/api_constants.dart';
import 'package:my_app/module/services/device_id.dart';
import 'package:my_app/module/services/secure_storage.dart';

enum ChangePinStep { current, newPin, confirm }

class ChangePinController extends GetxController {
  var currentStep = ChangePinStep.current.obs;
  var enteredPin = ''.obs;
  var oldPin = ''.obs;
  var newPin = ''.obs;
  var isLoading = false.obs;

  void addNumber(int number) {
    if (enteredPin.value.length < 6) {
      enteredPin.value += number.toString();
    }

    if (enteredPin.value.length == 6) {
      Future.delayed(const Duration(milliseconds: 200), () => _handleStepComplete());
    }
  }

  void deleteNumber() {
    if (enteredPin.value.isNotEmpty) {
      enteredPin.value = enteredPin.value.substring(0, enteredPin.value.length - 1);
    }
  }

  void _handleStepComplete() {
    if (currentStep.value == ChangePinStep.current) {
      // ขั้นตอนที่ 1: เก็บ PIN ปัจจุบันและไปหน้าตั้งรหัสใหม่
      oldPin.value = enteredPin.value;
      enteredPin.value = '';
      currentStep.value = ChangePinStep.newPin;
    } else if (currentStep.value == ChangePinStep.newPin) {
      // ขั้นตอนที่ 2: เก็บ PIN ใหม่และไปหน้ายืนยัน
      newPin.value = enteredPin.value;
      enteredPin.value = '';
      currentStep.value = ChangePinStep.confirm;
    } else if (currentStep.value == ChangePinStep.confirm) {
      // ขั้นตอนที่ 3: ตรวจสอบว่าตรงกันไหมแล้วยิง API
      if (enteredPin.value == newPin.value) {
        _processChangePin();
      } else {
        Get.snackbar('ผิดพลาด', 'รหัสผ่านใหม่ไม่ตรงกัน');
        enteredPin.value = '';
      }
    }
  }

  Future<void> _processChangePin() async {
    try {
      isLoading.value = true;
      String? token = await storage.read(key: 'accessToken');
      String? deviceId = await getDeviceId();

      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}${ApiConstants.changePassword}"), // ตรวจสอบ endpoint ของคุณ
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "oldPin": oldPin.value,
          "newPin": newPin.value,
          "deviceId": deviceId,
        }),
      );

      if (response.statusCode == 200) {
        // ✅ เปลี่ยนสำเร็จ ไปหน้า Success ตาม Figma
        Get.offNamed('/success_page', arguments: {
          "title": "เปลี่ยนรหัส PIN สำเร็จ",
          "subtitle": "รหัสผ่านของคุณถูกเปลี่ยนเรียบร้อยแล้ว",
        });
      } else {
        Get.snackbar('ผิดพลาด', 'ไม่สามารถเปลี่ยนรหัสได้ กรุณาตรวจสอบรหัสเดิม');
        // รีเซ็ตกลับไปเริ่มใหม่
        reset();
      }
    } catch (e) {
      Get.snackbar('Error', 'เกิดข้อผิดพลาดในการเชื่อมต่อ');
    } finally {
      isLoading.value = false;
    }
  }

  void reset() {
    currentStep.value = ChangePinStep.current;
    enteredPin.value = '';
    oldPin.value = '';
    newPin.value = '';
  }
}