import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/module/controller/type_cards_controller.dart';

class Type_Cards extends StatelessWidget {
  const Type_Cards({super.key});

  @override
  Widget build(BuildContext context) {
    final TypeCardsController controller = Get.put(TypeCardsController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF264FAD),
        title: const Text('สมัครบัตรเดบิต', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ส่วนหัวสีเทาอ่อน
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[200],
            child: const Text(
              'เลือกประเภทบัตรที่คุณต้องการ',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
            ),
          ),
          
          // รายการบัตร
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView.separated(
                itemCount: controller.cardList.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  var card = controller.cardList[index];
                  return _buildCardItem(card);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCardItem(dynamic card) {
    // แปลงรูปภาพ Base64
    Uint8List? imageBytes;
    if (card['type_debit_image'] != null) {
      String base64String = card['type_debit_image'].split(',').last;
      imageBytes = base64Decode(base64String);
    }

    return InkWell(
      onTap: () {
        // ไปหน้าถัดไปพร้อมส่งข้อมูลบัตรที่เลือก
        Get.toNamed('/card_detail', arguments: card);
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              card['type_debit_name'] ?? 'Debit Card',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // รูปหน้าบัตร
                Container(
                  width: 120,
                  height: 75,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[300],
                  ),
                  child: imageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(imageBytes, fit: BoxFit.cover),
                        )
                      : const Icon(Icons.credit_card, size: 40),
                ),
                const SizedBox(width: 16),
                // คำอธิบาย
                Expanded(
                  child: Text(
                    card['type_debit_description'] ?? '-',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}