import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/views/widgets/arrow_fab.dart'; // ตรวจสอบ path ของคุณ

class Card_Detail extends StatefulWidget {
  const Card_Detail({super.key});

  @override
  State<Card_Detail> createState() => _Card_DetailState();
}

class _Card_DetailState extends State<Card_Detail> {
  final dynamic cardData = Get.arguments;

  // 1. เพิ่ม ValueNotifier เพื่อควบคุมปุ่ม "ต่อไป" โดยไม่ใช้ setState ทั้งหน้า
  final ValueNotifier<bool> isButtonEnabled = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    // 2. Decode รูปภาพครั้งเดียวใน build
    Uint8List? imageBytes;
    if (cardData['type_debit_image'] != null) {
      String base64String = cardData['type_debit_image'].split(',').last;
      imageBytes = base64Decode(base64String);
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

            // ส่วนแสดงบัตร (จะไม่กระพริบแล้วเพราะเราแยก State ของ Checkbox)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 50),
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
                    cardData['type_debit_name'] ?? '-',
                    style: const TextStyle(
                      fontSize: 18,
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

                  // 3. เรียกใช้ TermsCheckbox ที่แยก State มาแล้ว
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

      // 4. ส่วนปุ่มด้านล่างปรับให้เหมือน Figma
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ฝั่งซ้าย: ยกเลิก
              GestureDetector(
                onTap: () => Get.back(),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'ยกเลิก',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // ฝั่งขวา: ต่อไป + ArrowFab
              ValueListenableBuilder<bool>(
                valueListenable: isButtonEnabled,
                builder: (context, enabled, child) {
                  return Row(
                    children: [
                      Text(
                        'ต่อไป',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          // ข้อความเปลี่ยนจากสีเทาเป็นสีเขียวเข้มหรือดำเมื่อเปิดใช้งาน
                          color: enabled
                              ? const Color.fromARGB(255, 45, 75, 10)
                              : Colors.grey[400],
                          
                        ),
                      ),
                      const SizedBox(width: 12),
                      // ตัวปุ่ม ArrowFab จะเปลี่ยนสีเองตาม Logic ภายในที่เราแก้ไว้ด้านบน
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

// 5. คลาส TermsCheckbox (คงเดิมตามที่คุณให้มา)
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
