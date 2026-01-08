import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/core/api_constants.dart';
import 'package:my_app/module/controller/changelimit_controller.dart';
import 'package:my_app/module/services/device_id.dart';
import 'package:my_app/module/services/secure_storage.dart';

class PinVerifyController extends GetxController {
  var enteredPin = ''.obs;
  var isLoading = false.obs;

  // รับข้อมูลบัตรที่ส่งมาจากหน้า Confirm
  final dynamic cardData = Get.arguments;
  final dynamic args = Get.arguments;

  void addNumber(int number) {
    if (enteredPin.value.length < 6) {
      enteredPin.value += number.toString();
    }
    if (enteredPin.value.length == 6) {
      // เมื่อครบ 6 หลัก ให้ยิง API ทันที
      if (args['action'] == 'view_sensitive') {
        processViewSensitiveData();
      } else if (args['action'] == 'change_limit') {
        processChangeLimit();
      } else {
        createVirtualCard();
      }
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

  //สร้างบัตรเดบิต
  Future<void> createVirtualCard() async {
    try {
      isLoading.value = true;
      String? token = await storage.read(key: 'accessToken');
      String? deviceId = await getDeviceId();

      // เตรียม Data ตามที่ Postman กำหนด
      Map<String, dynamic> body = {
        "pin": enteredPin.value,
        "deviceId": deviceId,
        "typeDebitId": cardData['type_debit_id'], // ID บัตรที่เลือกมา
      };

      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}${ApiConstants.createcard}"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // ต้องแนบ Token ไปด้วย
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // สร้างสำเร็จ ไปหน้า Success
        Get.offAllNamed(
          '/success_createcard',
          arguments: {
            "title": "สร้างบัตรสำเร็จ!",
            "subtitle": "ระบบกำลังดำเนินการเปิดใช้งานบัตรของคุณ",
          },
        );
      } else {
        final errorData = jsonDecode(utf8.decode(response.bodyBytes));
        Get.snackbar('ผิดพลาด', errorData['message'] ?? 'รหัสผ่านไม่ถูกต้อง');
        enteredPin.value = ''; // ล้างรหัสให้กรอกใหม่
      }
    } catch (e) {
      Get.snackbar('Error', 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้');
      enteredPin.value = '';
    } finally {
      isLoading.value = false;
    }
  }

  //เปลี่ยนวงเงิน
  Future<void> processChangeLimit() async {
    try {
      isLoading.value = true;
      String? deviceId = await getDeviceId();
      final ChangelimitController limitController = Get.put(
        ChangelimitController(),
      );

      // เรียกใช้ฟังก์ชัน updateSpendingLimit ใน ChangelimitController
      bool success = await limitController.updateSpendingLimit(
        args['card_id'],
        args['amount'],
        enteredPin.value,
        deviceId ?? '',
      );

      if (success) {
        // Get.offAllNamed('/success_createcard', arguments: {
        //   "title": "ปรับวงเงินสำเร็จ!",
        //   "subtitle": "ระบบได้ทำการปรับเปลี่ยนวงเงินการใช้จ่ายของคุณแล้ว"
        // });
        Get.offAllNamed('/success_change_limit');
      } else {
        Get.snackbar(
          'ผิดพลาด',
          'รหัสผ่านไม่ถูกต้อง หรือไม่สามารถเปลี่ยนวงเงินได้',
        );
        enteredPin.value = '';
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> processViewSensitiveData() async {
    try {
      isLoading.value = true;
      String? token = await storage.read(key: 'accessToken');
      String? deviceId = await getDeviceId();

      final response = await http.post(
        Uri.parse(
          "${ApiConstants.baseUrl}${ApiConstants.sensitive.replaceFirst('{card_id}', args['card']['card_id'])}",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"pin": enteredPin.value, "deviceId": deviceId}),
      );

      if (response.statusCode == 200) {
        final sensitiveData = jsonDecode(utf8.decode(response.bodyBytes));
        // ✅ ส่งข้อมูลที่ได้จาก API ไปแสดงที่หน้า SensitiveDataPage
        Get.offNamed(
          '/sensitive',
          arguments: {
            'card': args['card'],
            'ownerName': args['ownerName'],
            'sensitive':
                sensitiveData, // ข้อมูลจาก API: expiry, encrypted_pan, encrypted_cvv
          },
        );
      } else {
        Get.snackbar('ผิดพลาด', 'รหัสผ่านไม่ถูกต้อง');
        enteredPin.value = '';
      }
    } catch (e) {
      Get.snackbar('Error', 'เกิดข้อผิดพลาดในการเชื่อมต่อ');
    } finally {
      isLoading.value = false;
    }
  }

  // ในส่วน addNumber อย่าลืมเช็คเงื่อนไข
}
