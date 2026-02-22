import 'package:get/get.dart';
import 'package:my_app/core/service/api_constants.dart';
import 'package:my_app/core/service/api_service.dart'; // นำเข้า ApiService
import 'package:my_app/module/services/device_id.dart';
import 'package:dio/dio.dart' as dio; // นำเข้าเพื่อใช้จัดการ DioException

enum ChangePinStep { current, newPin, confirm }

class ChangePinController extends GetxController {
  var currentStep = ChangePinStep.current.obs;
  var enteredPin = ''.obs;
  var oldPin = ''.obs;
  var newPin = ''.obs;
  var isLoading = false.obs;

  // สร้าง instance ของ ApiService เพื่อใช้ระบบ Interceptor
  final ApiService _apiService = ApiService();

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
      oldPin.value = enteredPin.value;
      enteredPin.value = '';
      currentStep.value = ChangePinStep.newPin;
    } else if (currentStep.value == ChangePinStep.newPin) {
      newPin.value = enteredPin.value;
      enteredPin.value = '';
      currentStep.value = ChangePinStep.confirm;
    } else if (currentStep.value == ChangePinStep.confirm) {
      if (enteredPin.value == newPin.value) {
        _processChangePin();
      } else {
        Get.snackbar('ผิดพลาด', 'รหัสผ่านใหม่ไม่ตรงกัน');
        enteredPin.value = '';
      }
    }
  }

  void handleBackStep() {
    if (currentStep.value == ChangePinStep.newPin) {
      currentStep.value = ChangePinStep.current;
      enteredPin.value = '';
    } else if (currentStep.value == ChangePinStep.confirm) {
      currentStep.value = ChangePinStep.newPin;
      enteredPin.value = '';
    } else {
      Get.back();
    }
  }

  Future<void> _processChangePin() async {
    try {
      isLoading.value = true;
      String? deviceId = await getDeviceId();

      // เปลี่ยนมาใช้ _apiService.instance.post
      // ไม่ต้องใส่ Header เองแล้ว เพราะ Interceptor จะจัดการให้
      final response = await _apiService.instance.post(
        ApiConstants.changePassword, 
        data: {
          "oldPin": oldPin.value,
          "newPin": newPin.value,
          "deviceId": deviceId,
        },
      );

      if (response.statusCode == 200) {
        Get.offNamed('/success_page', arguments: {
          "title": "เปลี่ยนรหัส PIN สำเร็จ",
          "subtitle": "รหัสผ่านของคุณถูกเปลี่ยนเรียบร้อยแล้ว",
        });
      }
    } on dio.DioException catch (e) {
      // จัดการ Error ผ่าน DioException เช่น รหัสเดิมไม่ถูกต้อง (400/401)
      String responseMessage = e.response?.data?['message'] ?? '';
        responseMessage = e.response?.data['error'];
      
      Get.snackbar('ผิดพลาด', responseMessage);
      reset();
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
