import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/core/api_constants.dart';
import 'package:my_app/module/services/secure_storage.dart';

class MyCardsController extends GetxController {
  var isLoading = true.obs;
  var myCards = [].obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyCards();
  }

  Future<void> fetchMyCards() async {
    try {
      isLoading.value = true;
      String? token = await storage.read(key: 'accessToken');

      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}${ApiConstants.mycards}"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

     if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        myCards.assignAll(data); // อัปเดตข้อมูลบัตรทั้งหมด
        print("ดึงข้อมูลบัตรสำเร็จ: ${myCards.length} ใบ");
      } else {
        myCards.clear();
      }
    } catch (e) {
      print("Error fetching cards: $e");
      myCards.clear();
    } finally {
      isLoading.value = false;
    }
  }
}