import 'package:get/get.dart';
import 'package:my_app/core/service/api_constants.dart';
import 'package:my_app/core/service/api_service.dart';

class PhonenumberController extends GetxController {
  var phoneNumber = ''.obs;
  var isLoading = false.obs;
  var REF_CODE = ''.obs; // <--- เพิ่มตัวแปรเก็บเลขอ้างอิง
  final ApiService _apiService = ApiService(); // <--- สร้าง instance ของ ApiService
  void setPhoneNumber(String number) {
    phoneNumber.value = number;
  }

  void reset() {
    phoneNumber.value = '';
    isLoading.value = false;
    REF_CODE.value = '';
  }

  // --------------------------------------------------------------------------------------------
  //
  Future<bool> submitPhone() async {
    try {
      isLoading.value = true;
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.refCode}');

      final response = await _apiService.instance.post(
        ApiConstants.refCode,
        data: {
          'mobileNumber': phoneNumber.value
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // *** สำคัญ: ต้องเอาค่าจาก JSON มาใส่ใน REF_CODE.value ***
        // สมมติว่า Server ส่งกลับมาในรูปแบบ {"REF_CODE": "ABC123"}
        if (data['refCode'] != null) {
          REF_CODE.value = data['refCode'].toString();
        }

        return true;
      } else {
        Get.snackbar('Error', 'Server error: ${response.statusCode}');
        return false;
      }
    } catch (e) {

      Get.snackbar('Error', 'เชื่อมต่อไม่ได้: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
