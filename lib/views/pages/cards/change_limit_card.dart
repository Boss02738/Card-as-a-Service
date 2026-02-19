import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_app/module/controller/changelimit_controller.dart';
import 'package:my_app/views/widgets/debitcard.dart';

class ChangeLimitCard extends StatefulWidget {
  const ChangeLimitCard({super.key});

  @override
  State<ChangeLimitCard> createState() => _ChangeLimitCardState();
}

class _ChangeLimitCardState extends State<ChangeLimitCard> {
  // 1. รับข้อมูลบัตรที่ส่งมาจาก Arguments
  final dynamic data = Get.arguments;
  late dynamic card;
  late String ownerName;
  late double originalLimit; // วงเงินเดิมไว้เทียบ
  final ChangelimitController limitController = Get.put(
    ChangelimitController(),
  );

  // ตัวแปรสำหรับเก็บค่าวงเงินที่เลือก
  String? selectedLimit;
  void _handleSave() async {
    double newLimit = double.parse(selectedLimit!);
    String cardId = card['card_id'];

    if (newLimit > originalLimit) {
      // ✅ กรณีเพิ่มวงเงิน: ไปหน้าใส่ PIN ก่อน
      // ส่งข้อมูล card และ newLimit ไปด้วยเพื่อให้หน้า PIN รู้ว่าต้องทำอะไรเมื่อใส่ถูก
      Get.toNamed(
        '/pin_verify_page',
        arguments: {
          'action': 'change_limit',
          'card_id': cardId,
          'amount': newLimit,
        },
      );
    } else if (newLimit < originalLimit) {
      // ✅ กรณีลดวงเงิน: บันทึกได้เลยไม่ต้องใส่ PIN
      bool success = await limitController.updateSpendingLimit(
        cardId,
        newLimit,
        '', // ไม่ต้องใช้ PIN เมื่อลดวงเงิน
        '', // ไม่ต้องใช้ deviceId เมื่อลดวงเงิน
      );
      if (success) {
        Get.back();
        Get.snackbar("สำเร็จ", "ปรับลดวงเงินเรียบร้อยแล้ว");
      } else {
        Get.snackbar("ผิดพลาด", "ไม่สามารถเปลี่ยนวงเงินได้");
      }
    } else {
      Get.back();
    }
  }

  @override
  void initState() {
    super.initState();
    card = data['card'];
    ownerName = data['ownerName'];
    originalLimit = (card['current_spending_limit'] as num).toDouble();
    selectedLimit = originalLimit.toInt().toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // พื้นหลังเทาอ่อนตาม Figma
      appBar: AppBar(
        title: const Text(
          'จัดการวงเงิน',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF264FAD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
            child: BankCard(
              card: card,
              ownerName: ownerName,
              cardName: card['card_name'],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      "ปรับเปลี่ยนวงเงิน",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 3. ส่วน Dropdown เลือกวงเงินตาม Figma
                  // ภายใน Column ของ build method
                  const Text(
                    "วงเงินใช้จ่ายต่อวัน",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // ✅ เปลี่ยนมาเป็น InkWell เพื่อกดเปิด Modal ตามรูป
                  InkWell(
                    onTap: _showLimitPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${selectedLimit?.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}.00",
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                  //
                  const SizedBox(height: 10),
                  const Text(
                    "วงเงินใช้จ่ายบัตรต่อวัน",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Obx(
            () => SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: limitController.isLoading.value ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF264FAD),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: limitController.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "บันทึก",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }


  void _showLimitPicker() {
    final List<String> limitOptions = [
      "1000",
      "3000",
      "5000",
      "10000",
      "20000",
      "30000",
      "50000",
      "100000",
      "200000",
      "500000",
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "เลือกวงเงินใช้จ่ายต่อวัน",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: limitOptions.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    String option = limitOptions[index];
                    bool isSelected = selectedLimit == option;

                    return ListTile(
                      title: Text(
                        "${option.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}.00",
                        style: TextStyle(
                          color: isSelected
                              ? const Color(0xFF264FAD)
                              : Colors.black87,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.blue,
                            ) // เครื่องหมายถูกตามรูป
                          : null,
                      onTap: () {
                        setState(() => selectedLimit = option);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
