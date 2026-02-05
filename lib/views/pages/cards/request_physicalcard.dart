import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/module/controller/type_cards_controller.dart';
import 'package:my_app/views/pages/Create_cards/card_details.dart';
import 'package:my_app/views/widgets/arrow_fab.dart';

class RequestPhysical extends StatefulWidget {
  const RequestPhysical({super.key});
  @override
  State<RequestPhysical> createState() => _RequestPhysicaState();
}

class _RequestPhysicaState extends State<RequestPhysical> {
  // รับข้อมูลจาก arguments
  final dynamic args = Get.arguments;
  final ValueNotifier<bool> isButtonEnabled = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final dynamic card = args['card']; // ข้อมูลบัตรปัจจุบันจากหน้า MyCardDetail

    // ดึง Controller มาใช้งาน (ใช้ find เพราะควรถูกสร้างมาจากหน้า List ประเภทบัตรแล้ว)
    final TypeCardsController typeController = Get.put(TypeCardsController());
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF264FAD),
        title: const Text(
          'รายละเอียดบัตรแข็ง',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      // ✅ ใช้ Obx ครอบคลุมเนื้อหาทั้งหมดที่ต้องใช้ข้อมูลจาก cardList
      body: Obx(() {
        // 🔍 ค้นหาข้อมูลภายใน Obx เพื่อให้ UI วาดใหม่เมื่อ cardList เปลี่ยนแปลง
        final dynamic cardTypeDetail = typeController.cardList.firstWhere(
          (t) => t['type_debit_id'] == card['type_debit_id'],
          orElse: () => null,
        );

        // Decode รูปภาพภายใน Obx
        Uint8List? imageBytes;
        if (cardTypeDetail != null &&
            cardTypeDetail['type_debit_image'] != null) {
          String base64String = cardTypeDetail['type_debit_image']
              .split(',')
              .last;
          imageBytes = base64Decode(base64String);
        }

        // แสดง Loading หากข้อมูลยังโหลดไม่เสร็จ
        if (typeController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ส่วน Header รายละเอียดบัตร
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.grey[200],
                child: const Text(
                  'รายละเอียดบัตร',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ),

              // ส่วนแสดงภาพบัตร (ใช้ imageBytes ที่ Decode มาจริง)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 30,
                  horizontal: 40,
                ),
                color: Colors.grey[50],
                child: Column(
                  children: [
                    if (imageBytes != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.memory(imageBytes, fit: BoxFit.contain),
                      )
                    else
                      const Icon(
                        Icons.credit_card,
                        size: 150,
                        color: Colors.grey,
                      ),
                    const SizedBox(height: 15),
                    Text(
                      cardTypeDetail?['type_debit_name'] ?? 'บัตรเดบิต NovaPay',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ค่าธรรมเนียม',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // ✅ แสดงค่าธรรมเนียมที่ดึงมาจาก cardTypeDetail
                    _buildFeeRow(
                      'ค่าธรรมเนียมออกบัตรใหม่',
                      '${cardTypeDetail?['entrance_fee'] ?? '0.00'} บาท',
                    ),
                    _buildFeeRow(
                      'ค่าธรรมเนียมรายปี',
                      '${cardTypeDetail?['annual_fee'] ?? '0.00'} บาท',
                    ),

                    const Divider(height: 40),
                    const Text(
                      'รายละเอียด',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // ✅ แสดงรายละเอียดจริงจาก API
                    Text(
                      cardTypeDetail?['type_debit_description'] ?? '-',
                      style: const TextStyle(
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 30),
                    TermsCheckbox(
                      onChanged: (val) => isButtonEnabled.value = val,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ฟังก์ชันช่วยสร้างแถวค่าธรรมเนียมให้สวยงาม
  Widget _buildFeeRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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
            ValueListenableBuilder<bool>(
              valueListenable: isButtonEnabled,
              builder: (context, enabled, child) {
                return Row(
                  children: [
                    Text(
                      'ยืนยัน',
                      style: TextStyle(
                        fontSize: 18,
                        color: enabled
                            ? const Color.fromARGB(255, 0, 0, 0)
                            : Colors.grey[400],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ArrowFab(
                      enabled: enabled,
                      onPressed: () {
                        // ไปหน้ากรอกที่อยู่จัดส่ง
                        Get.toNamed('/address_input', arguments: args);
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
