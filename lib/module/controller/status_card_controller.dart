import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/core/api_constants.dart';
import 'package:my_app/module/controller/my_cards_controller.dart';
import 'package:my_app/module/services/device_id.dart';
import 'package:my_app/module/services/secure_storage.dart';

class StatusCardController extends GetxController {
  var isLoading = false.obs;
  var isCardFrozen = false.obs;

  Future<void> freezeCard(String cardId) async {
    try {
      isLoading.value = true;
      String? token = await storage.read(key: 'accessToken');

      final response = await http.post(
        Uri.parse(
          "${ApiConstants.baseUrl}${ApiConstants.freeze.replaceFirst('{card_id}', cardId)}",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        isCardFrozen.value = true; // ✅ อัปเดตสถานะในแอป
        Get.find<MyCardsController>().fetchUserCards();
        Get.snackbar('Success', 'บัตรถูกระงับการใช้งานเรียบร้อยแล้ว');
      } else {
        Get.snackbar('Error', 'ไม่สามารถระงับการใช้งานบัตรได้');
      }
    } catch (e) {
      Get.snackbar('Error', 'เกิดข้อผิดพลาดในการเชื่อมต่อ');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> unfreezeCard(String cardId) async {
    try {
      isLoading.value = true;
      String? token = await storage.read(key: 'accessToken');

      final response = await http.post(
        Uri.parse(
          "${ApiConstants.baseUrl}${ApiConstants.unfreeze.replaceFirst('{card_id}', cardId)}",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        isCardFrozen.value = false;
        Get.find<MyCardsController>().fetchUserCards();
        Get.snackbar('Success', 'บัตรถูกเปิดใช้งานเรียบร้อยแล้ว');
      } else {
        Get.snackbar('Error', 'ไม่สามารถเปิดใช้งานบัตรได้');
      }
    } catch (e) {
      Get.snackbar('Error', 'เกิดข้อผิดพลาดในการเชื่อมต่อ');
    } finally {
      isLoading.value = false;
    }
  }
}
