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
        title: const Text(
          'สมัครบัตรเดบิต',
          style: TextStyle(color: Colors.white),
        ),
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
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
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
    // 1. ดึง String base64 จาก key 'type_debit_image' ตามใน API
    final String? base64String = card['type_debit_image'];
    Uint8List? imageBytes;
    

    // 2. แปลง String base64 เป็น Uint8List
    if (base64String != null && base64String.isNotEmpty) {
      try {
        // บางครั้ง Base64 จาก API อาจจะมี Header ติดมา เช่น "data:image/png;base64," 
        // ถ้ามีให้ทำการ split ออกก่อน แต่จากรูปที่คุณส่งมาน่าจะเป็น Pure Base64 เลย
        imageBytes = base64Decode(base64String);
      } catch (e) {
        debugPrint("Error decoding base64: $e");
      }
    }

    return InkWell(
      onTap: () {
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
                // ✅ รูปหน้าบัตร (เปลี่ยนจาก Network เป็น Memory)
                Container(
                  width: 120,
                  height: 75,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[300],
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: imageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            imageBytes, // 🖼️ ใช้ Image.memory สำหรับรูปที่เป็น Byte
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 40),
                          ),
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
