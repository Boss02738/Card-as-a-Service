import 'dart:convert';
import 'package:get/get.dart';
import 'package:my_app/core/service/api_service.dart';
import 'package:my_app/module/controller/info_controller.dart';
import 'package:my_app/module/controller/phonenumber_controller.dart';
import 'package:my_app/core/service/api_constants.dart';
import 'package:my_app/module/services/device_id.dart'; // import ไฟล์ที่เก็บฟังก์ชัน getDeviceId
import 'package:my_app/module/services/secure_storage.dart';

class PinController extends GetxController {
  var enteredPin = ''.obs; // PIN ที่กำลังพิมพ์
  var firstPin = ''.obs; // เก็บ PIN รอบแรก
  var isConfirmMode = false.obs; // สลับโหมด ตั้งค่า/ยืนยัน
  var isLoading = false.obs;
  final ApiService _apiService = ApiService();
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
    String? action = (args is Map) ? args['action'] : null;

    if (action == 'change_device_flow') {
      verifyOldPinAndChangeDevice();
    } else {
      if (!isConfirmMode.value) {
        firstPin.value = enteredPin.value; // เก็บค่ารหัสรอบแรกไว้
        enteredPin.value = '';

        isConfirmMode.value = true;
      } else {
        if (enteredPin.value == firstPin.value) {
          if (action == 'register') {
            registerUser();
          } else if (action == 'forgot_password_reset') {
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
      if (mobile.isEmpty) {
        Get.snackbar('ผิดพลาด', 'ไม่พบข้อมูลเบอร์โทรศัพท์');
        return;
      }
      Map<String, dynamic> body = {
        "citizenId": args['citizenId'],
        "accountNumber": args['accountNumber'],
        "pin": enteredPin.value,
        "mobileNumber": mobile,
        "newDeviceId": deviceId,
      };

      print("Request Body: ${jsonEncode(body)}");
      final response = await _apiService.instance.post(
        ApiConstants.changedevice,
        data: body,
      );

      if (response.statusCode == 200) {
        await storage.write(key: 'userMobile', value: mobile);
        await storage.write(key: 'isRegistered', value: 'true');
        await storage.write(key: 'deviceId', value: deviceId ?? "");

        Get.snackbar('สำเร็จ', 'ยืนยันตัวตนสำเร็จ กรุณาเข้าสู่ระบบ');

        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAllNamed('/success');
      } else {
        Get.snackbar(
          'ผิดพลาด',
          response.data['message'] ??
              'ข้อมูลไม่ถูกต้อง กรุณาตรวจสอบข้อมูลอีกครั้ง',
        );
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

      final dynamic args = Get.arguments;
      String mobile = "";

      if (args is Map && args.containsKey('mobileNumber')) {
        mobile = args['mobileNumber'] ?? "";
      }

      // ถ้าไม่มีเบอร์โทรศัพท์ ให้แจ้งเตือนแทนการปล่อยให้ Error
      if (mobile.isEmpty) {
        Get.snackbar('ผิดพลาด', 'ไม่พบข้อมูลเบอร์โทรศัพท์ในระบบ');
        return;
      }

      Map<String, dynamic> body = {
        "mobileNumber": mobile,
        "newPin": firstPin.value,
        "deviceId": deviceId,
      };

      final response = await _apiService.instance.post(
        ApiConstants.forgetPassword,
        data: body,
      );

      if (response.statusCode == 200) {
        Get.snackbar('สำเร็จ', 'รีเซ็ตรหัสผ่านใหม่เรียบร้อยแล้ว');
        // ล้างค่าก่อนย้ายหน้า
        enteredPin.value = '';
        firstPin.value = '';
        isConfirmMode.value = false;

        // await Future.delayed(const Duration(milliseconds: 500));
        Get.offAllNamed('/login-pin');
      } else {
        final error = response.data;
        Get.snackbar('ผิดพลาด', error['message'] ?? 'รีเซ็ตรหัสผ่านไม่สำเร็จ');
        enteredPin.value = ''; // ให้ User ลองกรอก Confirm PIN ใหม่
      }
    } catch (e) {
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
    final phoneCtrl = Get.find<PhonenumberController>();
    try {
      isLoading.value = true;
      String? deviceId = await getDeviceId();
      String mobile = phoneCtrl.phoneNumber.value;
      // ส่ง API โดยใช้ lockedMobile
      Map<String, dynamic> finalData = {
        "mobileNumber": mobile,
        ...infoCtrl.toJson(),
        "pin": firstPin.value,
        "deviceId": deviceId,
      };

      final response = await _apiService.instance.post(
        ApiConstants.register,
        data: finalData,
      );

      if (response.statusCode == 200) {
        // ใช้ lockedMobile ในการบันทึกลงเครื่อง
        // await storage.write(key: 'userMobile', value: lockedMobile);

        await storage.write(key: 'deviceId', value: deviceId ?? "");
        await storage.write(key: 'isRegistered', value: 'true');
        await storage.write(
          key: 'userMobile',
          value: Get.arguments['verifiedMobile'],
        );
        Get.snackbar('สำเร็จ', 'สมัครสมาชิกเรียบร้อยแล้ว');
        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAllNamed('/success');
      } else {
        Get.snackbar(
          'ผิดพลาด',
          'การลงทะเบียนไม่สำเร็จ: ${response.data['message'] ?? 'โปรดลองอีกครั้ง'}',
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
