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
    "citizenId": idCardCtrl.text,
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
  // ตรวจเช็คช่องกรอกข้อมูล


// เพิ่มฟังก์ชันแปลงวันที่จาก 26/12/2025 เป็น 2025-12-26 ตามที่ DB ต้องการ
String formatBirthDate(String date) {
  try {
    List<String> parts = date.split('/');
    return "${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}";
  } catch (e) {
    return date; 
  }
}
}
