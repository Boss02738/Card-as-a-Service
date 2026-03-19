import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart'
    as dio; // นำเข้า Dio และตั้งชื่อเล่นว่า dio เพื่อจัดการ Exception
import 'package:get/get.dart';
import 'package:my_app/core/service/api_constants.dart';
import 'package:my_app/core/service/api_service.dart';
import 'package:my_app/module/controller/changelimit_controller.dart';
import 'package:my_app/module/services/device_id.dart';
import 'package:my_app/module/services/secure_storage.dart';

class PinVerifyController extends GetxController {
  var enteredPin = ''.obs;
  var isLoading = false.obs;
  final ApiService _apiService = ApiService();

  // รับข้อมูลบัตรที่ส่งมาจากหน้า Confirm
  final dynamic cardData = Get.arguments;
  late Map<String, dynamic> args;

  @override
  void onInit() {
    super.onInit();
    // ดึง arguments มาเก็บไว้ในรูป Map
    args = Get.arguments is Map ? Map<String, dynamic>.from(Get.arguments) : {};
  }

  void addNumber(int number) {
    if (enteredPin.value.length < 6) {
      enteredPin.value += number.toString();
      print("Current PIN: ${enteredPin.value}"); // Check PIN ที่หน้าจอ Debug
    }
    if (enteredPin.value.length == 6) {
      // เพิ่มเงื่อนไขเช็ค action ขอบัตรแข็ง
      if (args['action'] == 'request_physical') {
        // processRequestPhysical({args['card']['card_id']});
        processRequestPhysical();
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

  // ฟังก์ชันใหม่สำหรับตรวจสอบ PIN แอปก่อนตั้งรหัสบัตร
  Future<void> processFinalActivate(
    String newCardPin,
    dynamic originalArgs,
  ) async {
    try {
      isLoading.value = true;
      String? deviceId = await getDeviceId();

      Map<String, dynamic> body = {
        "pin": enteredPin.value, // PIN แอปที่ส่งมาจากขั้นตอนก่อนหน้า
        "deviceId": deviceId,
        "lastDigits": originalArgs['input_data']['last_digits'],
        "expiry": originalArgs['input_data']['expiry'],
        "cvv": originalArgs['input_data']['cvv'],
        "newCardPin": newCardPin, // รหัส ATM 6 หลักที่ตั้งใหม่
        "card_id":
            originalArgs['card']['card_id'], //  เพิ่มบรรทัดนี้เพื่อให้ API รู้ว่าเปิดใบไหน
      };

      final response = await _apiService.instance.post(
        ApiConstants.activatecard,
        data: body,
      );

      if (response.statusCode == 200) {
        Get.offAllNamed(
          '/success_page',
          arguments: {
            "title": "เปิดใช้งานสำเร็จ",
            "subtitle": "บัตรของคุณพร้อมใช้งานแล้ว",
          },
        );
      }
    } on dio.DioException catch (e) {
      // จัดการ Error แบบ Dio
      String errorMessage = 'ไม่สามารถเปิดใช้งานบัตรได้';
      if (e.response?.data != null && e.response?.data['message'] != null) {
        errorMessage = e.response?.data['message'];
      }
      Get.snackbar('ผิดพลาด', errorMessage);
    } catch (e) {
      Get.snackbar('Error', 'เกิดข้อผิดพลาดในการเชื่อมต่อ');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyAppPinForActivation() async {
    try {
      isLoading.value = true;
      String? deviceId = await getDeviceId();
      String? mobile = await storage.read(key: 'userMobile');

      final response = await _apiService.instance.post(
        ApiConstants.verifyPin,
        data: {
          // "mobileNumber": mobile,
          "pin": enteredPin.value,
          "deviceId": deviceId,
        },
      );
      print(
        "Response from verifyPin API: ${response.data}",
      ); // ✅ Check Response จาก API
      if (response.statusCode == 200) {
        Get.toNamed(
          '/set_card_pin',
          arguments: {...args, 'app_pin': enteredPin.value},
        );
      }
    } on dio.DioException catch (e) {
      // ✅ ตรงนี้ e จะมี Property response แน่นอน
      enteredPin.value = '';
      
      String errorMessage = "รหัสผ่านไม่ถูกต้อง";
      
      if (e.response != null) {
        // กรณี Server ตอบกลับมา (เช่น 401, 400)
        final data = e.response?.data;
        // ดึงข้อความจากโครงสร้าง JSON ของเพื่อน (message หรือ error)
        errorMessage = data?['message'] ?? data?['error'] ?? "ข้อมูลไม่ถูกต้อง";
        print("❌ Server Response: $data");
      } else {
        // กรณีเชื่อมต่อไม่ได้เลย (Timeout/No Internet)
        errorMessage = "ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้ (${e.type})";
      }

      Get.snackbar('ผิดพลาด', errorMessage);
      
    } catch (e) {
      // ✅ สำหรับ Error อื่นๆ ที่ไม่ใช่ Network (เช่น Logic พัง)
      print("❌ Local Error: $e");
      Get.snackbar('Error', 'เกิดข้อผิดพลาดภายในแอป');
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

  // สร้างบัตรเดบิต
  Future<void> createVirtualCard() async {
    try {
      isLoading.value = true;
      String? deviceId = await getDeviceId();

      Map<String, dynamic> body = {
        "pin": enteredPin.value,
        "deviceId": deviceId,
        "typeDebitId": cardData['type_debit_id'],
      };

      final response = await _apiService.instance.post(
        ApiConstants.createcard,
        data: body,
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
      }
    } on dio.DioException catch (e) {
      String errorMessage = 'เกิดข้อผิดพลาดในการสร้างบัตร';

      if (e.response?.data != null) {
        // 1. ดึง String จาก key 'error' ออกมาก่อน
        String rawError = e.response?.data['error'].toString() ?? "";

        // 2. ตรวจสอบว่าใน String นั้นมีคำว่า "message" อยู่ไหม
        if (rawError.contains('"message":"')) {
          // ดึงข้อความระหว่าง "message":" กับ " ออกมา
          errorMessage = rawError.split('"message":"')[1].split('"')[0];
        } else {
          errorMessage = rawError;
        }
      }

      Get.snackbar('ผิดพลาด', errorMessage);
      enteredPin.value = '';
    } catch (e) {
      Get.snackbar('Error', 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้');
      enteredPin.value = '';
    } finally {
      isLoading.value = false;
    }
  }

  // เปลี่ยนวงเงิน
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
        // controller นั้นจัดการ error snackbar ให้แล้ว แต่เราล้าง pin ที่นี่
        enteredPin.value = '';
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> processViewSensitiveData(cardId) async {
    try {
      isLoading.value = true;
      String? deviceId = await getDeviceId();

      final response = await _apiService.instance.post(
        ApiConstants.sensitive,
        data: {
          "pin": enteredPin.value,
          "deviceId": deviceId,
          "card_id": args['card_id'],
        },
      );

      if (response.statusCode == 200) {
        // Dio แปลง json ให้แล้ว เรียกใช้ response.data ได้เลย
        final sensitiveData = response.data;
        //  ส่งข้อมูลที่ได้จาก API ไปแสดงที่หน้า SensitiveDataPage
        Get.offNamed(
          '/sensitive',
          arguments: {
            'card': args['card'],
            'ownerName': args['ownerName'],
            'sensitive': sensitiveData,
          },
        );
      }
    } on dio.DioException catch (e) {
      Get.snackbar('ผิดพลาด', 'รหัสผ่านไม่ถูกต้อง');
      enteredPin.value = '';
    } catch (e) {
      Get.snackbar('Error', 'เกิดข้อผิดพลาดในการเชื่อมต่อ');
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ แก้ไข: ลบ (cardId) ออก
  Future<void> processRequestPhysical() async {
    try {
      isLoading.value = true;
      String? deviceId = await getDeviceId();

      // ดึงที่อยู่จาก args ที่ส่งต่อมาจากหน้า Address
      Map<String, dynamic> addressInfo = args['addressData'] ?? {};

      // ✅ บังคับทุกค่าเป็น String ป้องกัน Error จากฝั่ง Server
      Map<String, dynamic> requestBody = {
        "address": "${addressInfo['address']}",
        "subdistrict": "${addressInfo['subdistrict']}",
        "district": "${addressInfo['district']}",
        "province": "${addressInfo['province']}",
        "zipcode": "${addressInfo['zipcode']}",
        "pin": enteredPin.value.toString(), // ✅ ตรวจสอบว่าตรงกับรหัสเข้าแอป
        "deviceId": deviceId?.toString() ?? "",
        "card_id": args['card']['card_id'].toString(),
      };

      print("🚀 Final Payload sending to Server: $requestBody");

      final response = await _apiService.instance.post(
        ApiConstants.requestphysicalcard,
        data: requestBody,
      );

      if (response.statusCode == 200) {
        Get.offAllNamed(
          '/success_page',
          arguments: {
            "title": "ขอบัตรแข็งสำเร็จ!",
            "subtitle": "ระบบกำลังจัดส่งบัตรไปยังที่อยู่ของคุณ",
          },
        );
      }
    } on dio.DioException catch (e) {
      // ✅ ถ้า Error ให้ล้าง PIN ทันทีเพื่อให้ User กรอกใหม่ได้ถูกต้อง
      enteredPin.value = '';

      String errorMessage = ' ${e.response?.data}';
      print("❌ Server Error Response: ${e.response?.data}");
      if (e.response?.data != null && e.response?.data['message'] != null) {
        errorMessage = e.response?.data['message'];
      }
      Get.snackbar('ผิดพลาด', errorMessage);
    } catch (e) {
      enteredPin.value = '';
      Get.snackbar('Error', 'เกิดข้อผิดพลาดในการเชื่อมต่อ');
    } finally {
      isLoading.value = false;
    }
  }
}
