import 'dart:convert'; // ✅ ต้อง import เพื่อใช้ base64Decode
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/views/widgets/arrow_fab.dart';

class Card_Detail extends StatefulWidget {
  const Card_Detail({super.key});

  @override
  State<Card_Detail> createState() => _Card_DetailState();
}

class _Card_DetailState extends State<Card_Detail> {
  final dynamic cardData = Get.arguments;
  final ValueNotifier<bool> isButtonEnabled = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    // 1. ดึงข้อมูล Base64 String
    final String? base64String = cardData['type_debit_image'];
    Uint8List? imageBytes;

    // 2. แปลง Base64 เป็น Bytes
    if (base64String != null && base64String.isNotEmpty) {
      try {
        imageBytes = base64Decode(base64String);
      } catch (e) {
        debugPrint("Error decoding base64: $e");
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF264FAD),
        title: const Text(
          'สมัครบัตรเดบิต',
          style: TextStyle(color: Colors.white),
        ),
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

            // ✅ ส่วนแสดงบัตรที่แก้ไขแล้ว
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 50),
              color: Colors.grey[50],
              child: Column(
                children: [
                  imageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.memory(
                            imageBytes,
                            fit: BoxFit.cover,
                            width: double.infinity, // ปรับขนาดให้เต็ม Container
                          ),
                        )
                      : const Icon(Icons.credit_card, size: 150, color: Colors.grey),
                  const SizedBox(height: 15),
                  Text(
                    cardData['type_debit_name'] ?? '-', // ใช้คีย์ให้ตรงกับ API
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  _buildFeeRow(
                    'ค่าธรรมเนียมออกบัตรใหม่',
                    '${cardData['entrance_fee'] ?? '0.00'} บาท',
                  ),
                  _buildFeeRow(
                    'ค่าธรรมเนียมรายปี',
                    '${cardData['annual_fee'] ?? '0.00'} บาท',
                  ),
                  const Divider(height: 40),
                  const Text(
                    'รายละเอียด',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    cardData['type_debit_description'] ?? '-',
                    style: const TextStyle(color: Colors.black87, height: 1.5),
                  ),
                  const SizedBox(height: 40),
                  TermsCheckbox(
                    onChanged: (val) {
                      isButtonEnabled.value = val;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
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
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'ยกเลิก',
                      style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: isButtonEnabled,
                builder: (context, enabled, child) {
                  return Row(
                    children: [
                      Text(
                        'ต่อไป',
                        style: TextStyle(
                          fontSize: 18,
                          color: enabled ? const Color(0xFF2D4B0A) : Colors.grey[400],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ArrowFab(
                        enabled: enabled,
                        onPressed: () {
                          Get.toNamed('/card_confirm', arguments: cardData);
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

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
}

// ... คงส่วน TermsCheckbox ไว้เหมือนเดิม ...


class TermsCheckbox extends StatefulWidget {
  final Function(bool) onChanged;
  const TermsCheckbox({super.key, required this.onChanged});

  @override
  State<TermsCheckbox> createState() => _TermsCheckboxState();
}

class _TermsCheckboxState extends State<TermsCheckbox> {
  bool isAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: isAccepted,
          onChanged: (value) {
            setState(() => isAccepted = value!);
            widget.onChanged(isAccepted);
          },
          activeColor: const Color(0xFF264FAD),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        const Expanded(
          child: Text(
            'ยอมรับเงื่อนไขการสมัครบัตรเดบิต',
            style: TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
