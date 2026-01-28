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
      //  เพิ่มเงื่อนไขเช็ค action ขอบัตรแข็ง
      if (args['action'] == 'request_physical') {
        processRequestPhysical({args['card']['card_id']});
      } else if (args['action'] == 'view_sensitive') {
        processViewSensitiveData({});
      } else if (args['action'] == 'change_limit') {
        processChangeLimit();
      } else if (args['action'] == 'activate_physical_flow') {
        verifyAppPinForActivation();
      } else {
        createVirtualCard();
      }
    }
  }

  // ✅ ฟังก์ชันใหม่สำหรับตรวจสอบ PIN แอปก่อนตั้งรหัสบัตร
  // // ในไฟล์ pin_verify_controller.dart
  Future<void> processFinalActivate(
    String newCardPin,
    dynamic originalArgs,
  ) async {
    try {
      isLoading.value = true;
      String? token = await storage.read(key: 'accessToken');
      String? deviceId = await getDeviceId();

      Map<String, dynamic> body = {
        "pin": enteredPin.value, // PIN แอปที่ส่งมาจากขั้นตอนก่อนหน้า
        "deviceId": deviceId,
        "lastDigits": originalArgs['input_data']['last_digits'],
        "expiry": originalArgs['input_data']['expiry'],
        "cvv": originalArgs['input_data']['cvv'],
        "newCardPin": newCardPin, // รหัส ATM 6 หลักที่ตั้งใหม่
        "card_id": originalArgs['card']['card_id'], // ✅ เพิ่มบรรทัดนี้เพื่อให้ API รู้ว่าเปิดใบไหน
      };

      final response = await http.post(
        Uri.parse(
          "${ApiConstants.baseUrl}${ApiConstants.activatecard}",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // ✅ สำเร็จ! ไปหน้า Success
        Get.offAllNamed(
          '/success_page',
          arguments: {
            "title": "เปิดใช้งานสำเร็จ",
            "subtitle": "บัตรของคุณพร้อมใช้งานแล้ว",
          },
        );
      } else {
        final errorData = jsonDecode(utf8.decode(response.bodyBytes));
        Get.snackbar(
          'ผิดพลาด',
          errorData['message'] ?? 'ไม่สามารถเปิดใช้งานบัตรได้',
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'เกิดข้อผิดพลาดในการเชื่อมต่อ');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyAppPinForActivation() async {
    try {
      isLoading.value = true;
      String? token = await storage.read(key: 'accessToken');
      String? deviceId = await getDeviceId();

      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}${ApiConstants.sensitive}"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "pin": enteredPin.value,
          "deviceId": deviceId,
          "card_id": args['card']['card_id']
        }),
      );

      if (response.statusCode == 200) {

        Get.toNamed(
          '/set_card_pin',
          arguments: {
            ...args,
            'app_pin': enteredPin.value,
          },
        );
      } else {
        // ❌ PIN ผิด (ตามที่ Backend ตอบกลับ)
        Get.snackbar('ผิดพลาด', 'รหัสผ่านไม่ถูกต้อง');
        enteredPin.value = '';
      }
    } catch (e) {
      Get.snackbar('Error', 'เกิดข้อผิดพลาดในการเชื่อมต่อ');
      enteredPin.value = '';
    } finally {
      isLoading.value = false;
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

      Map<String, dynamic> body = {
        "pin": enteredPin.value,
        "deviceId": deviceId,
        "typeDebitId": cardData['type_debit_id'],
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
          '/success_page',
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
        Get.offAllNamed(
          '/success_page',
          arguments: {
            "title": "ปรับวงเงินสำเร็จ!",
            "subtitle": "ระบบได้ทำการปรับเปลี่ยนวงเงินการใช้จ่ายของคุณแล้ว",
          },
        );
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

  Future<void> processViewSensitiveData(cardId) async {
    try {
      isLoading.value = true;
      String? token = await storage.read(key: 'accessToken');
      String? deviceId = await getDeviceId();

      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}${ApiConstants.sensitive}"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "pin": enteredPin.value,
          "deviceId": deviceId,
          "card_id": args['card_id'],
        }),
      );

      if (response.statusCode == 200) {
        final sensitiveData = jsonDecode(utf8.decode(response.bodyBytes));
        // ✅ ส่งข้อมูลที่ได้จาก API ไปแสดงที่หน้า SensitiveDataPage
        Get.offNamed(
          '/sensitive',
          arguments: {
            'card': args['card'],
            'ownerName': args['ownerName'],
            'sensitive': sensitiveData,
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

Future<void> processRequestPhysical(cardId) async {
  try {
    isLoading.value = true;
    String? token = await storage.read(key: 'accessToken');
    String? deviceId = await getDeviceId();

    // 📦 1. ดึงข้อมูลที่อยู่จาก arguments ที่ส่งมาจากหน้าก่อนหน้า
    Map<String, dynamic> addressInfo = args['addressData'];

    // 📦 2. รวมข้อมูลทั้งหมด (ที่อยู่ + PIN + DeviceID + CardID) เข้าเป็นก้อนเดียว
    // ให้ตรงตามโครงสร้างใน Postman
    // Map<String, dynamic> requestBody = {
    //   ...addressInfo,        
    //   "pin": enteredPin.value, 
    //   "deviceId": deviceId,    
    //   "card_id": cardId,     
    // };
    Map<String, dynamic> requestBody = {
      "address": addressInfo['address'],
      "subdistrict": addressInfo['subdistrict'],
      "district": addressInfo['district'],
      "province": addressInfo['province'],
      "zipcode": addressInfo['zipcode'],
      "pin": enteredPin.value, // PIN 6 หลักที่ User เพิ่งกรอก
      "deviceId": deviceId,
      "card_id": args['card']['card_id'], // ✅ ใส่ card_id รวมเข้าไปในนี้
    };

    // 🚀 3. ยิง API โดยใช้ Body ที่รวมข้อมูลครบแล้ว
    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}${ApiConstants.requestphysicalcard}"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(requestBody), 
    );

    if (response.statusCode == 200) {
      Get.offAllNamed(
        '/success_page',
        arguments: {
          "title": "ขอบัตรแข็งสำเร็จ!",
          "subtitle": "ระบบกำลังจัดส่งบัตรไปยังที่อยู่ของคุณ",
        },
      );
    } else {
      final errorData = jsonDecode(utf8.decode(response.bodyBytes));
      Get.snackbar(
        'ผิดพลาด',
        errorData['message'] ?? 'ไม่สามารถดำเนินการได้',
      );
      enteredPin.value = '';
    }
  } catch (e) {
    Get.snackbar('Error', 'เกิดข้อผิดพลาดในการเชื่อมต่อ');
    enteredPin.value = '';
  } finally {
    isLoading.value = false;
  }
}
  // Future<void> processRequestPhysical(cardId) async {
  //   try {
  //     isLoading.value = true;
  //     String? token = await storage.read(key: 'accessToken');
  //     String? deviceId = await getDeviceId();

  //     // 📦 เตรียม Body ข้อมูล (ที่อยู่ + PIN + DeviceID)
  //     Map<String, dynamic> addressInfo = args['addressData'];
  //     Map<String, dynamic> body = {
  //       ...addressInfo, // ดึงข้อมูลที่อยู่จากหน้า Address
  //       "pin": enteredPin.value,
  //       "deviceId": deviceId,
        
  //     };

  //     // 🚀 ยิง API เส้น requestphysicalcard
  //     final response = await http.post(
  //       Uri.parse(
  //         "${ApiConstants.baseUrl}${ApiConstants.requestphysicalcard}",
  //       ),
  //       headers: {
  //         "Content-Type": "application/json",
  //         "Authorization": "Bearer $token",
  //       },
  //       body: jsonEncode({"card_id": cardId}), // ส่ง card_id ใน request body
  //     );

  //     if (response.statusCode == 200) {
  //       Get.offAllNamed(
  //         '/success_page',
  //         arguments: {
  //           "title": "ขอบัตรแข็งสำเร็จ!",
  //           "subtitle": "ระบบกำลังจัดส่งบัตรไปยังที่อยู่ของคุณ",
  //         },
  //       );
  //     } else {
  //       final errorData = jsonDecode(utf8.decode(response.bodyBytes));
  //       Get.snackbar(
  //         'ผิดพลาด',
  //         errorData['message'] ?? 'ไม่สามารถดำเนินการได้',
  //       );
  //       enteredPin.value = '';
  //     }
  //   } catch (e) {
  //     Get.snackbar('Error', 'เกิดข้อผิดพลาดในการเชื่อมต่อ');
  //     enteredPin.value = '';
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }
}
