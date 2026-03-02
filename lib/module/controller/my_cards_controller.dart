import 'package:get/get.dart';
import 'package:my_app/core/service/api_constants.dart';
import 'package:my_app/core/service/api_service.dart';
import 'package:my_app/core/utils/screen_size.dart'; 

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
      String screenType = getDeviceSizeCategory();
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
        // print('Screen size category: $screenType');
        myCards.assignAll(data);
      } else {
        myCards.clear();
      }
    } catch (e) {
      // print("Fetch Cards Error: $e");
      myCards.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void fetchUserCards() async {
    await fetchMyCards();
  }

}