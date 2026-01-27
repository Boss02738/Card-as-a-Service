// card_detail_view_controller.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/core/api_constants.dart';
import 'package:my_app/module/services/secure_storage.dart';

class CardDetailController extends GetxController {
  var isLoading = true.obs;
  var cardData = {}.obs;

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
        body: jsonEncode({"card_id": cardId}), // ส่ง card_id ใน request body
      );

      if (response.statusCode == 200) {
        cardData.value = jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        Get.snackbar('Error', 'ไม่สามารถดึงข้อมูลรายละเอียดบัตรได้');
      }
    } catch (e) {
      Get.snackbar('Error', 'เกิดข้อผิดพลาดในการเชื่อมต่อ');
    } finally {
      isLoading.value = false;
    }
  }
}