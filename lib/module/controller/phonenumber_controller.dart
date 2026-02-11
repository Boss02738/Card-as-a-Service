import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:my_app/core/api_constants.dart';

class PhonenumberController extends GetxController {
  var phoneNumber = ''.obs;
  var isLoading = false.obs;
  var REF_CODE = ''.obs; // <--- เพิ่มตัวแปรเก็บเลขอ้างอิง

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

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        // body: jsonEncode({'phoneNumber': phoneNumber.value}),
        body: jsonEncode({'mobileNumber': phoneNumber.value}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

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
