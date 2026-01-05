import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/core/api_constants.dart';
import 'package:my_app/module/services/secure_storage.dart';

class TypeCardsController extends GetxController {
  var isLoading = true.obs;
  var cardList = [].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCardTypes();
  }

  Future<void> fetchCardTypes() async {
    try {
      isLoading.value = true;
      String? token = await storage.read(key: 'accessToken');

      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}${ApiConstants.typecards}"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        // ดึงข้อมูลเป็น List ของบัตร
        cardList.value = jsonDecode(utf8.decode(response.bodyBytes));
      }
    } catch (e) {
      Get.snackbar('Error', 'ไม่สามารถโหลดข้อมูลประเภทบัตรได้');
    } finally {
      isLoading.value = false;
    }
  }
}