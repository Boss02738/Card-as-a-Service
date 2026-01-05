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
        
        // สมมติว่า API ส่งมาในรูปแบบ {"token": "xxxxxx", ...}
        String? token = responseData['token']; 

        if (token != null) {
          // บันทึก Token ลงเครื่อง
          await storage.write(key: 'accessToken', value: token);
          print("DEBUG: บันทึก Token สำเร็จ");
          
          Get.offAllNamed('/home'); // เข้าหน้าหลัก
        } else {
          Get.snackbar('Error', 'ไม่ได้รับรหัสยืนยันจากระบบ (Token is null)');
        }
        // ---------------------------
      } else {
        Get.snackbar('ผิดพลาด', 'รหัสผ่านไม่ถูกต้อง');
        enteredPin.value = '';
      }
    } catch (e) {
      Get.snackbar('Error', 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้: $e');
      enteredPin.value = '';
    } finally {
      isLoading.value = false;
    }
  }
}
