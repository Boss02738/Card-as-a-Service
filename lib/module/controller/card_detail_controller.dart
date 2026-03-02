// card_detail_controller.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:my_app/core/service/api_constants.dart';
import 'package:my_app/core/service/api_service.dart';
import 'package:my_app/core/utils/screen_size.dart';
import 'package:my_app/module/services/secure_storage.dart';
import 'package:dio/dio.dart' as dio; // นำเข้าเพื่อใช้จัดการ DioException

class CardDetailController extends GetxController {
  var isLoading = true.obs;
  var cardData = {}.obs;
  var trackingData = {}.obs;
  final ApiService _apiService = ApiService();

  Future<void> fetchCardDetail(String cardId) async {
    try {
      isLoading.value = true;
      String screenType = getDeviceSizeCategory();

      final response = await _apiService.instance.post(
        ApiConstants.cardDetail,
        data: {"card_id": cardId},
        queryParameters: {'image_size': screenType},
      );

      if (response.statusCode == 200) {
        cardData.value = response
            .data; // ถ้าเป็นบัตร Physical และสถานะยังไม่ active ให้เรียกดู tracking ต่อทันที
        // print('Screen size category: $screenType');

        if (cardData['virtual'] == false && cardData['status'] == 'inactive') {
          await fetchCardTracking(cardId);
        }
      }
    } on dio.DioException catch (e) {
      // ดักจับ Error จาก Dio โดยเฉพาะ
      // print("Card Detail Error: ${e.message}");
      Get.snackbar('Error', 'ไม่สามารถดึงข้อมูลรายละเอียดบัตรได้');
    } catch (e) {
      Get.snackbar('Error', 'เกิดข้อผิดพลาดไม่คาดคิด');
    } finally {
      isLoading.value = false;
    }
  }

  //  ปรับปรุงฟังก์ชัน Tracking
  Future<void> fetchCardTracking(String cardId) async {
    try {
      final response = await _apiService.instance.post(
        ApiConstants.cardTraking,
        data: {"card_id": cardId}, 
      );

      if (response.statusCode == 200) {
        trackingData.value = response.data;
      }
    } on dio.DioException catch (e) {
      // print("Card Tracking Error: ${e.message}");
      Get.snackbar('Error', 'ไม่สามารถดึงข้อมูลการติดตามบัตรได้');
    } catch (e) {
      Get.snackbar('Error', 'เกิดข้อผิดพลาดไม่คาดคิด');
    }
  }
}
