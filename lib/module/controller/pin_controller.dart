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
  final dynamic args = Get.arguments;
  final String? action = args is Map ? args['action'] : null;

  if (action == 'change_device_flow') {
    // ✅ สำหรับ Flow เปลี่ยนเครื่อง: ยิง API เช็ค PIN เดิมทันที
    verifyOldPinAndChangeDevice();
  } else {
    // Flow อื่นๆ (สมัครใหม่/ลืมรหัส) ที่ต้องกรอก 2 รอบ
    if (!isConfirmMode.value) {
      // สำหรับ Register: ล็อกค่าเบอร์โทรไว้
      try {
        final phoneCtrl = Get.find<PhonenumberController>();
        lockedMobile = phoneCtrl.phoneNumber.value;
      } catch (e) {
        print("Register controller not found");
      }

      firstPin.value = enteredPin.value;
      enteredPin.value = '';
      isConfirmMode.value = true;
    } else {
      // ตรวจสอบ PIN รอบสอง
      if (enteredPin.value == firstPin.value) {
        if (action == 'forgot_password_reset') {
          processResetPassword();
        } else {
          registerUser();
        }
      } else {
        Get.snackbar('ผิดพลาด', 'รหัสผ่านไม่ตรงกัน');
        enteredPin.value = '';
      }
    }
  }
}

Future<void> verifyOldPinAndChangeDevice() async {
  try {
    isLoading.value = true;
    String? deviceId = await getDeviceId();
    final dynamic args = Get.arguments;

    // ดึงเบอร์โทรศัพท์ที่ส่งมาจากหน้า ChangeDevicePage หรือ FaceVerify
    String mobile = args['mobileNumber'] ?? "";

    Map<String, dynamic> body = {
      "citizenId": args['citizenId'],
      "accountNumber": args['accountNumber'],
      "pin": enteredPin.value,
      "mobileNumber": mobile,
      "newDeviceId": deviceId,
    };

    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}${ApiConstants.changedevice}"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      // ✅ จุดที่ต้องแก้ไข: บันทึกข้อมูลลงเครื่องใหม่เพื่อให้ Login ได้
      await storage.write(key: 'userMobile', value: mobile); 
      await storage.write(key: 'isRegistered', value: 'true');
      
      print("DEBUG: บันทึกเบอร์ $mobile ลงเครื่องใหม่สำเร็จ");

      Get.snackbar('สำเร็จ', 'ยืนยันตัวตนสำเร็จ กรุณาเข้าสู่ระบบ');
      
      // หน่วงเวลาเล็กน้อยเพื่อให้ระบบบันทึกค่าเสร็จสิ้นก่อนย้ายหน้า
      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed('/login-pin'); 
    } else {
      final error = jsonDecode(utf8.decode(response.bodyBytes));
      Get.snackbar('ผิดพลาด', error['message'] ?? 'ข้อมูลไม่ถูกต้อง กรุณาตรวจสอบข้อมูลอีกครั้ง');
      enteredPin.value = '';
    }
  } catch (e) {
    Get.snackbar('Error', 'เกิดข้อผิดพลาดในการเชื่อมต่อ: $e');
  } finally {
    isLoading.value = false;
  }
}

  Future<void> processResetPassword() async {
    try {
      isLoading.value = true;
      String? deviceId = await getDeviceId();

      // 🔍 เช็ค Arguments ให้ละเอียด
      final dynamic args = Get.arguments;
      String mobile = "";

      if (args is Map && args.containsKey('mobileNumber')) {
        mobile = args['mobileNumber'] ?? "";
      }

      // 🛡️ ถ้าไม่มีเบอร์โทรศัพท์ ให้แจ้งเตือนแทนการปล่อยให้ Error
      if (mobile.isEmpty) {
        Get.snackbar('ผิดพลาด', 'ไม่พบข้อมูลเบอร์โทรศัพท์ในระบบ');
        return;
      }

      Map<String, dynamic> body = {
        "mobileNumber": mobile,
        "newPin": firstPin.value,
        "deviceId": deviceId,
      };

      print("DEBUG: Sending Reset PIN Request for $mobile");

      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}${ApiConstants.forgetPassword}"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      print("DEBUG: API Response Code: ${response.statusCode}");
      print("DEBUG: API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        Get.snackbar('สำเร็จ', 'รีเซ็ตรหัสผ่านใหม่เรียบร้อยแล้ว');
        // ล้างค่าก่อนย้ายหน้า
        enteredPin.value = '';
        firstPin.value = '';
        isConfirmMode.value = false;

        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAllNamed('/pin_login'); // กลับไปหน้า Login
      } else {
        final error = jsonDecode(utf8.decode(response.bodyBytes));
        Get.snackbar('ผิดพลาด', error['message'] ?? 'รีเซ็ตรหัสผ่านไม่สำเร็จ');
        enteredPin.value = ''; // ให้ User ลองกรอก Confirm PIN ใหม่
      }
    } catch (e) {
      print("DEBUG: Catch Error: $e"); // ดู Error ใน Log ว่าติดที่บรรทัดไหน
      Get.snackbar('Error', 'เกิดข้อผิดพลาดในการเชื่อมต่อ: $e');
    } finally {
      isLoading.value = false;
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
