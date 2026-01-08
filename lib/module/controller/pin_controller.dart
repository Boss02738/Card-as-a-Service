import 'dart:convert';

import 'package:get/get.dart';
import 'package:my_app/module/controller/info_controller.dart';
import 'package:my_app/module/controller/phonenumber_controller.dart';
import 'package:my_app/core/api_constants.dart';
import 'package:my_app/module/services/device_id.dart'; // import ไฟล์ที่เก็บฟังก์ชัน getDeviceId
import 'package:my_app/module/services/secure_storage.dart';
import 'package:http/http.dart' as http;

class PinController extends GetxController {
  var enteredPin = ''.obs; // PIN ที่กำลังพิมพ์
  var firstPin = ''.obs; // เก็บ PIN รอบแรก
  var isConfirmMode = false.obs; // สลับโหมด ตั้งค่า/ยืนยัน
  var isLoading = false.obs;

  String lockedMobile = "";
  //pin
  void addNumber(int number) {
    if (enteredPin.value.length < 6) {
      enteredPin.value += number.toString();
    }

    // เมื่อครบ 6 หลัก
    if (enteredPin.value.length == 6) {
      Future.delayed(const Duration(milliseconds: 200), () {
        handlePinComplete();
      });
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
  void handlePinComplete() {
  if (!isConfirmMode.value) {
    // จังหวะที่ PIN รอบแรกเสร็จ ให้ดึงเบอร์จาก Controller มาเก็บไว้ใน lockedMobile ทันที
    final phoneCtrl = Get.find<PhonenumberController>();
    lockedMobile = phoneCtrl.phoneNumber.value; 
    print("ล็อกค่าเบอร์โทรสำเร็จ: $lockedMobile"); // เพิ่มเพื่อเช็คใน Log

    firstPin.value = enteredPin.value;
    enteredPin.value = '';
    isConfirmMode.value = true;
  } else {
    if (enteredPin.value == firstPin.value) {
      registerUser();
    } else {
      Get.snackbar('ผิดพลาด', 'รหัสไม่ตรงกัน กรุณาลองใหม่');
      enteredPin.value = '';
    }
  }
}

  void goBackToSetPin() {
    isConfirmMode.value = false;
    enteredPin.value = '';
    firstPin.value = '';
  }

Future<void> registerUser() async {
  final infoCtrl = Get.find<InfoController>();
  try {
    isLoading.value = true;
    String? deviceId = await getDeviceId();

    // ส่ง API โดยใช้ lockedMobile
    Map<String, dynamic> finalData = {
      "mobileNumber": lockedMobile, 
      ...infoCtrl.toJson(),
      "pin": firstPin.value,
      "deviceId": deviceId,
    };

    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}${ApiConstants.register}"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(finalData),
    );

    if (response.statusCode == 200) {
      // ใช้ lockedMobile ในการบันทึกลงเครื่อง
      print("กำลังบันทึกข้อมูลลง Storage สำหรับเบอร์: $lockedMobile");
      
      await storage.write(key: 'userMobile', value: lockedMobile);
      await storage.write(key: 'deviceId', value: deviceId ?? "");
      await storage.write(key: 'isRegistered', value: 'true');

      print("บันทึกสำเร็จ! ค่าเบอร์คือ: $lockedMobile");
      
      Get.snackbar('สำเร็จ', 'สมัครสมาชิกเรียบร้อยแล้ว');
      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed('/success');
    } else {
        print("Server Error Detail: ${response.body}");
        Get.snackbar('ผิดพลาด', 'การลงทะเบียนไม่สำเร็จ: ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Error', 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
