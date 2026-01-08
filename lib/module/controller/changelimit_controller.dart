// changelimit_controller.dart
import 'dart:convert';

import 'package:my_app/core/api_constants.dart';
import 'package:my_app/module/controller/my_cards_controller.dart';
import 'package:get/get.dart';
import 'package:my_app/module/services/device_id.dart';
import 'package:my_app/module/services/secure_storage.dart';
import 'package:http/http.dart' as http;

class ChangelimitController extends GetxController {
  var isLoading = false.obs;
  
  Future<bool> updateSpendingLimit(String cardId, double newLimit,String? pin,String deviceId) async {
    try {
      isLoading.value = true;
      String? token = await storage.read(key: 'accessToken');
      String? deviceId = await getDeviceId();

      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}${ApiConstants.limitcard.replaceFirst('{card_id}', cardId)}"),
        headers: {
          'Content-Type': "application/json",
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "amount": newLimit,
          "pin": pin,
          "deviceId": deviceId,
        }),
      );

     if (response.statusCode == 200) {
        // อัปเดตข้อมูลบัตรใน MyCardsController ด้วยเพื่อให้หน้าอื่นเปลี่ยนตาม
        await Get.find<MyCardsController>().fetchMyCards();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}