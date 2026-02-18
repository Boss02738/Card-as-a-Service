import 'package:get/get.dart';
import 'package:my_app/core/api_constants.dart';
import 'package:my_app/core/api_service.dart'; // นำเข้า ApiService

class MyCardsController extends GetxController {
  var isLoading = true.obs;
  var myCards = [].obs;

  // สร้าง instance ของ ApiService
  final ApiService _apiService = ApiService();

  @override
  void onInit() {
    super.onInit();
    fetchMyCards();
  }

  Future<void> fetchMyCards() async {
    try {
      isLoading.value = true;
      String screenType = _getDeviceSizeCategory();
      // ไม่ต้องส่ง Header เองแล้ว เพราะ Interceptor ใน ApiService จัดการให้
      final response = await _apiService.instance.get(
        ApiConstants.mycards,
        queryParameters: {
          'image_size':
              screenType, 
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        myCards.assignAll(data);
      } else {
        myCards.clear();
      }
    } catch (e) {
      // หากเกิด Error 401 แล้ว Refresh Token ไม่ผ่าน
      // Interceptor จะพาไปหน้า Login เองตาม Logic ใน ApiService
      print("Fetch Cards Error: $e");
      myCards.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void fetchUserCards() async {
    await fetchMyCards();
  }
  // ฟังก์ชันช่วยวิเคราะห์ขนาดหน้าจอ
  String _getDeviceSizeCategory() {
    double width = Get.context!.width; 
    if (width < 600) {
      return 'image_small';
    } else if (width < 1200) {
      return 'image_medium';
    } else {
      return 'image_large';
    }
  }
}