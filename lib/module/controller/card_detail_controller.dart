// card_detail_controller.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/core/api_constants.dart';
import 'package:my_app/module/services/secure_storage.dart';

class CardDetailController extends GetxController {
  var isLoading = true.obs;
  var cardData = {}.obs;
  var trackingData = {}.obs; 

  Future<void> fetchCardDetail(String cardId) async {
    try {
      isLoading.value = true;
      String? token = await storage.read(key: 'accessToken');

      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}${ApiConstants.cardDetail}"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"card_id": cardId}), // ✅ ตรวจสอบว่าส่ง body แล้ว
      );

      if (response.statusCode == 200) {
        cardData.value = jsonDecode(utf8.decode(response.bodyBytes));
        // ✅ ถ้าเป็นบัตร Physical และสถานะยังไม่ active ให้เรียกดู tracking ต่อทันที
        if (cardData['virtual'] == false && cardData['status'] == 'inactive') {
          await fetchCardTracking(cardId);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'เกิดข้อผิดพลาดในการเชื่อมต่อรายละเอียดบัตร');
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ ปรับปรุงฟังก์ชัน Tracking
  Future<void> fetchCardTracking(String cardId) async {
    try {
      String? token = await storage.read(key: 'accessToken');
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}${ApiConstants.cardTraking}"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"card_id": cardId}),
      );

      if (response.statusCode == 200) {
        trackingData.value = jsonDecode(utf8.decode(response.bodyBytes));
      }
    } catch (e) {

    }
  }
}