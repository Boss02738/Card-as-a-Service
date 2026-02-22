import 'package:get/get.dart';
import 'package:my_app/core/service/api_constants.dart';
import 'package:my_app/core/service/api_service.dart';
import 'package:dio/dio.dart' as dio; // นำเข้าเพื่อจัดการ Exception

class HomeController extends GetxController {
  var isLoading = true.obs;
  
  // ข้อมูลบัญชีผู้ใช้
  var fullNameTh = ''.obs;
  var accountNumber = ''.obs;
  var accountType = ''.obs;
  var balance = 0.0.obs;
  var fullNameEn = ''.obs;
  var createdAt = ''.obs;
  var email = ''.obs;
  var number = ''.obs;

  final ApiService _apiService = ApiService();
  var myCards = [].obs;

  @override
  void onInit() {
    super.onInit();
    fetchHomeProfile();
  }

  Future<void> fetchHomeProfile() async {
    try {
      isLoading.value = true;

      // ✅ ไม่ต้องดึง token และใส่ Header เอง เพราะ ApiService จัดการให้แล้ว
      final response = await _apiService.instance.get(
        ApiConstants.account
      );

      if (response.statusCode == 200) {
        // ✅ Dio แปลงข้อมูลเป็น Map ให้แล้ว ใช้งานได้เลย
        final data = response.data;
        
        fullNameTh.value = data['fullNameTh'] ?? '';
        fullNameEn.value = data['fullNameEn'] ?? '';
        number.value = data['number'] ?? '';
        email.value = data['email'] ?? '';
        createdAt.value = data['createdAt'] ?? '';
        accountNumber.value = data['accountNumber'] ?? '';
        accountType.value = data['accountType'] ?? '';
        balance.value = (data['balance'] as num).toDouble();

        if (data['card_id'] != null) {
          // ✅ ใช้ assignAll สำหรับการอัปเดต List
          myCards.assignAll(data['card_id']); 
        } else {
          myCards.clear();
        }
      }
    } on dio.DioException catch (e) {
      // ✅ จัดการ Error เฉพาะทางของ Dio
      print("Home Profile Error: ${e.message}");
      Get.snackbar('Error', 'ไม่สามารถดึงข้อมูลบัญชีได้');
    } catch (e) {
      Get.snackbar('Error', 'เกิดข้อผิดพลาดไม่คาดคิด');
    } finally {
      isLoading.value = false;
    }
  }
}