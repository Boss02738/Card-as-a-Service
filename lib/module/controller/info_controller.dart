import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InfoController extends GetxController {
  final idCardCtrl = TextEditingController();
  final birthdayDateCtrl = TextEditingController();
  final firstNameThCtrl = TextEditingController();
  final lastNameThCtrl = TextEditingController();
  final firstNameEnCtrl = TextEditingController();
  final lastNameEnCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  var isLoading = false.obs;

  // ฟังก์ชันล้างข้อมูล form
  void clearForm() {
    idCardCtrl.clear();
    birthdayDateCtrl.clear();
    firstNameThCtrl.clear();
    lastNameThCtrl.clear();
    firstNameEnCtrl.clear();
    lastNameEnCtrl.clear();
    emailCtrl.clear();
  }

  // ฟังก์ชันรวบรวมข้อมูลเตรียมยิง API
Map<String, dynamic> toJson() {
  return {
    "citizenId": idCardCtrl.text.replaceAll('-', ''),
    "firstNameTh": firstNameThCtrl.text,
    "lastNameTh": lastNameThCtrl.text,
    "firstNameEn": firstNameEnCtrl.text,
    "lastNameEn": lastNameEnCtrl.text,
    "email": emailCtrl.text.trim(),
    "birthDate": formatBirthDate(birthdayDateCtrl.text), // ฟังก์ชันแปลงวันที่
  };
}

  @override
  void onClose() {
    // สำคัญมาก: ต้องคืน Memory เสมอ
    idCardCtrl.dispose();
    birthdayDateCtrl.dispose();
    firstNameThCtrl.dispose();
    lastNameThCtrl.dispose();
    firstNameEnCtrl.dispose();
    lastNameEnCtrl.dispose();
    emailCtrl.dispose();
    super.onClose();
  }

String formatBirthDate(String date) {
  try {
    // ถ้าผู้ใช้กรอก 01/12/1997 ให้เปลี่ยนเป็น 01-12-1997 ตามแบบ Postman
    return date.replaceAll('/', '-'); 
  } catch (e) {
    return date; 
  }
}
}
