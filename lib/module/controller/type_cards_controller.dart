import 'package:get/get.dart';
import 'package:my_app/core/service/api_constants.dart';
import 'package:my_app/core/service/api_service.dart';
import 'package:dio/dio.dart' as dio;
import 'package:my_app/core/utils/screen_size.dart'; // นำเข้าเพื่อใช้จัดการ Exception

class TypeCardsController extends GetxController {
  var isLoading = true.obs;
  var cardList = [].obs;
  
  // เรียกใช้ ApiService เพื่อให้ Interceptor ทำงาน
  final ApiService _apiService = ApiService();

  @override
  void onInit() {
    super.onInit();
    fetchCardTypes();
  }

  Future<void> fetchCardTypes() async {
    try {
      isLoading.value = true;
      String screentype = getDeviceSizeCategory(); 
      // ไม่ต้องดึง Token เองแล้ว เพราะ Interceptor ใน ApiService จัดการให้
      // เรียก API ผ่าน Dio instance
      final response = await _apiService.instance.get(
        ApiConstants.typecards,
        queryParameters: {
          'image_size': screentype,
        },
      );

      if (response.statusCode == 200) {
        // ✅ Dio แปลง JSON ให้อัตโนมัติ เรียกใช้ response.data ได้เลย
        // ใช้ assignAll เพื่ออัปเดต RxList ให้ UI รับรู้การเปลี่ยนแปลง
        screentype = getDeviceSizeCategory();
        // print('Screen size category: $screentype');
        if (response.data is List) {
          cardList.assignAll(response.data);
        }
      }
    } on dio.DioException catch (e) {
      // ดักจับ Error เฉพาะของ Dio
      // print("Fetch TypeCards Error: ${e.message}");
      Get.snackbar('Error', 'ไม่สามารถโหลดข้อมูลประเภทบัตรได้');
    } catch (e) {
      // Error อื่นๆ ทั่วไป
      Get.snackbar('Error', 'เกิดข้อผิดพลาดในการเชื่อมต่อ');
    } finally {
      isLoading.value = false;
    }
  }
}