import 'package:dio/dio.dart' as dio;
import 'package:my_app/core/api_constants.dart';
import 'package:my_app/core/api_service.dart';
import 'package:my_app/module/controller/my_cards_controller.dart';
import 'package:get/get.dart';
import 'package:my_app/module/services/device_id.dart';

class ChangelimitController extends GetxController {
  var isLoading = false.obs;
  final ApiService _apiService = ApiService();

  Future<bool> updateSpendingLimit(String cardId, double newLimit, String? pin, String deviceId) async {
    try {
      isLoading.value = true;
      
      // ✅ แนะนำให้เลือกใช้อย่างใดอย่างหนึ่ง ระหว่างรับมาจาก Parameter 
      // หรือดึงใหม่ข้างใน (ในที่นี้ขอใช้ค่าที่ดึงใหม่เพื่อให้มั่นใจว่าเป็น ID ล่าสุด)
      String? currentDeviceId = await getDeviceId();

      final response = await _apiService.instance.post(
        ApiConstants.limitcard,
        data: {
          "amount": newLimit,
          "pin": pin,
          "deviceId": currentDeviceId,
          "card_id": cardId
        },
      );

      if (response.statusCode == 200) {
        // อัปเดตข้อมูลบัตรเพื่อให้หน้าอื่นเปลี่ยนตาม
        await Get.find<MyCardsController>().fetchMyCards();
        return true;
      }
      return false;
    } on dio.DioException catch (e) {
      String errorMessage = 'ไม่สามารถเปลี่ยนวงเงินได้';
      if (e.response?.data != null && e.response?.data['message'] != null) {
        errorMessage = e.response?.data['message'];
      }
      Get.snackbar('ผิดพลาด', errorMessage);
      return false; // ✅ คืนค่า false เมื่อเกิด Error
    } catch (e) {
      Get.snackbar('Error', 'เกิดข้อผิดพลาดในการเชื่อมต่อ');
      return false; // ✅ คืนค่า false เมื่อเกิด Error
    } finally {
      isLoading.value = false;
    }
  }
}