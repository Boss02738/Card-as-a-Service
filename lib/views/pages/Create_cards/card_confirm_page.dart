import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/module/controller/home_controller.dart';
import 'package:my_app/views/widgets/arrow_fab.dart';

class Card_Confirm_Page extends StatelessWidget {
  const Card_Confirm_Page({super.key});

  @override
  Widget build(BuildContext context) {
    // ดึงข้อมูลที่ส่งมาจากหน้า Card_Detail
    final dynamic cardData = Get.arguments;
    // ดึงข้อมูลโปรไฟล์จาก HomeController
    final HomeController homeCtrl = Get.find<HomeController>();

    // เตรียมรูปภาพ Base64
    Uint8List? imageBytes;
    if (cardData['type_debit_image'] != null) {
      imageBytes = base64Decode(cardData['type_debit_image'].split(',').last);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF264FAD),
        title: const Text('บัตรของคุณ', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ส่วนหัวเทาอ่อน
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.grey[200],
              child: const Text(
                'รายละเอียดบัตร',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
              ),
            ),

            // ส่วนแสดงบัตรและข้อมูลผู้ถือบัตร
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
              color: Colors.grey[50],
              child: Column(
                children: [
                  if (imageBytes != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.memory(imageBytes, fit: BoxFit.contain),
                    ),
                  const SizedBox(height: 15),
                  Text(
                    cardData['type_debit_name'] ?? 'บัตรเดบิต NovaPay',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  // แสดงชื่อจาก API Profile
                  Text(
                    'ชื่อหน้าบัตร: ${homeCtrl.fullNameTh.value}',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  // แสดงเลขบัญชีจาก API Profile
                  Text(
                    'My-Account: ${homeCtrl.accountNumber.value}',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),

            // สรุปค่าธรรมเนียม
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('รายละเอียด', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 15),
                  _buildSummaryRow('ค่าธรรมเนียมออกบัตรใหม่', '${cardData['entrance_fee'] ?? '0.00'} บาท'),
                  _buildSummaryRow('ค่าธรรมเนียมรายปี', '${cardData['annual_fee'] ?? '0.00'} บาท'),
                  const Divider(height: 30),
                  _buildSummaryRow(
                    'รวม', 
                    '${(double.parse(cardData['entrance_fee'].toString()) + double.parse(cardData['annual_fee'].toString())).toStringAsFixed(2)} บาท',
                    isTotal: true
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'หมายเหตุ: เมื่อผู้ใช้ทำการสมัครบัตรเดบิตแล้ว ธนาคารจะสมัครบริการ Verified by VISA โดยอัตโนมัติผูกกับเบอร์มือถือนี้',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomAction(cardData),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isTotal ? 16 : 14, color: isTotal ? Colors.black : Colors.grey[600])),
          Text(value, style: TextStyle(fontSize: isTotal ? 18 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildBottomAction(dynamic cardData) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // ปุ่มยกเลิก
            GestureDetector(
              onTap: () => Get.back(),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text('ยกเลิก', style: TextStyle(color: Colors.grey, fontSize: 18)),
                ],
              ),
            ),
            
            // ปุ่มยืนยัน (ต่อไป)
            Row(
              children: [
                const Text('ต่อไป', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(width: 12),
                ArrowFab(
                  enabled: true, // หน้านี้เปิดให้กดได้เลย
                  onPressed: () {
                    // ไปหน้าใส่ PIN เพื่อยืนยันการสมัคร
                    Get.toNamed('/pin_verify_page', arguments: cardData);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}