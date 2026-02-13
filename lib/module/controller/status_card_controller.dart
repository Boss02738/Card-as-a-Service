import 'dart:convert';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/core/api_constants.dart';
import 'package:my_app/core/api_service.dart';
import 'package:my_app/module/controller/card_detail_controller.dart';
import 'package:my_app/module/controller/my_cards_controller.dart';
import 'package:my_app/module/services/secure_storage.dart';

// lib/module/controller/status_card_controller.dart
class StatusCardController extends GetxController {
  var isLoading = false.obs;
  var isCardFrozen = false.obs;
  final ApiService _apiService = ApiService();
  // ✅ ฟังก์ชันตั้งค่าสถานะเริ่มต้น (เรียกใช้ครั้งเดียวตอนเข้าหน้า Detail)
  void setInitialStatus(bool frozen) {
    isCardFrozen.value = frozen;
  }

  Future<void> freezeCard(String cardId) async {
    if (isLoading.value) return; // ป้องกันการกดย้ำ
    try {
      isLoading.value = true;

      final response = await _apiService.instance.post(
        ApiConstants.freeze,
         data: {"card_id": cardId}, // ส่ง card_id ใน request body
      );

      if (response.statusCode == 200) {
        isCardFrozen.value = true;
        Get.find<MyCardsController>().fetchMyCards(); // อัปเดต List หน้าแรก
        Get.find<CardDetailController>().fetchCardDetail(
          cardId,
        ); 
        Get.snackbar('สำเร็จ', 'ระงับบัตรเรียบร้อยแล้ว');
      }
    } on dio.DioException catch (e) {
      print("Card freeze Error: ${e.message}");
      Get.snackbar('Error', 'ไม่สามารถระงับบัตรได้');
    } catch (e) {
      Get.snackbar('Error', 'เกิดข้อผิดพลาดไม่คาดคิด');
    } finally {
      isLoading.value = false; 
    }
  }

  Future<void> unfreezeCard(String cardId) async {
    if (isLoading.value) return;
    try {
      isLoading.value = true;

      final response = await _apiService.instance.post(
        ApiConstants.unfreeze,
         data: {"card_id": cardId},
      );

      if (response.statusCode == 200) {
        isCardFrozen.value = false;
        Get.find<MyCardsController>().fetchMyCards();
        Get.find<CardDetailController>().fetchCardDetail(
          cardId,
        ); // ✅ อัปเดตข้อมูลหน้า Detail
        Get.snackbar('สำเร็จ', 'เปิดใช้งานบัตรเรียบร้อยแล้ว');
      }
    } on dio.DioException catch (e) {
      print("Card unfreeze Error: ${e.message}");
      Get.snackbar('Error', 'ไม่สามารถเปิดใช้งานบัตรได้');
    } catch (e) {
      Get.snackbar('Error', 'เกิดข้อผิดพลาดไม่คาดคิด');
    } finally {
      isLoading.value = false; 
    }
  }
}
