import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/core/api_constants.dart';
import 'package:my_app/module/services/secure_storage.dart';

class HomeController extends GetxController {
  var isLoading = true.obs;
  
  // ดึงบัญชีผู้ใช้
  var fullNameTh = ''.obs;
  var accountNumber = ''.obs;
  var accountType = ''.obs;
  var balance = 0.0.obs;
  var fullNameEn = ''.obs;
  var createdAt = ''.obs;
  var email = ''.obs;
  var number = ''.obs;
  // ดึงข้อมูลบัตรของฉัน
  var myCards = [].obs; // เก็บ List ของบัตรที่ดึงมาจาก API

  @override
  void onInit() {
    super.onInit();
    fetchHomeProfile(); // ดึงข้อมูลทันทีที่หน้า Home ถูกสร้าง
  }

  Future<void> fetchHomeProfile() async {
    try {
      isLoading.value = true;
      
      // ดึง Token จาก Secure Storage ที่บันทึกไว้ตอน Login
      String? token = await storage.read(key: 'accessToken');

      if (token == null) {
        Get.offAllNamed('/login'); 
        return;
      }

      // เรียก API โดยแนบ Bearer Token ใน Header
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}${ApiConstants.account}"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", 
        },
      );

      if (response.statusCode == 200) {
        // แปลงข้อมูลจาก UTF-8 เพื่อรองรับภาษาไทย
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        
        fullNameTh.value = data['fullNameTh'];
        fullNameEn.value = data['fullNameEn'];
        number.value = data['number'];
        email.value = data['email'];
        createdAt.value = data['createdAt'];
        accountNumber.value = data['accountNumber'];
        accountType.value = data['accountType'];
        balance.value = (data['balance'] as num).toDouble();
        

        if (data['card_id'] != null) {
          myCards.value = data['card_id']; 
          print("ดึงข้อมูลบัตรสำเร็จ: ${myCards.length} ใบ");
        } else {
          myCards.clear();
        }
      } else {
        print("Error: ${response.statusCode}");
        Get.snackbar('Error', 'ไม่สามารถดึงข้อมูลบัญชีได้');
      }
    } catch (e) {
      print("Exception: $e");
      Get.snackbar('Error', 'เกิดข้อผิดพลาดในการเชื่อมต่อ');
    } finally {
      isLoading.value = false;
    }
  }
}