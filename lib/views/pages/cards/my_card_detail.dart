import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/module/controller/card_detail_controller.dart';
import 'package:my_app/module/controller/home_controller.dart';
import 'package:my_app/module/controller/status_card_controller.dart';

class MyCardDetail extends StatefulWidget {
  const MyCardDetail({super.key});

  @override
  State<MyCardDetail> createState() => _MyCardDetailState();
}

class _MyCardDetailState extends State<MyCardDetail> {
  // ดึง Controller ที่จัดการข้อมูลรายละเอียดบัตร
  final detailController = Get.put(CardDetailController());
  final StatusCardController statusCardController = Get.put(
    StatusCardController(),
  );
  final HomeController homeController = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    // ✅ ดึงเฉพาะ card_id จาก arguments เพื่อนำไปเรียก API เส้น detail
    final String cardId = Get.arguments['card_id'];
    detailController.fetchCardDetail(cardId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'รายละเอียดบัตร',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF264FAD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final card = detailController.cardData;
        if (card.isEmpty) return const Center(child: Text("ไม่พบข้อมูลบัตร"));

        final String currentCardId = card['card_id'];
        final String ownerEn = homeController.fullNameEn.value;
        final String Cardname = card['card_name'];

        // ซิงค์สถานะการระงับบัตรกับ status controller
        bool isCurrentlyFrozen = card['status'] != 'active';
        statusCardController.isCardFrozen.value = isCurrentlyFrozen;
        // ✅ แก้ไขจุดนี้: เรียกใช้ฟังก์ชันตั้งค่าเริ่มต้นเพียงครั้งเดียว (หรือเช็คค่าก่อนเซ็ต)
        // ห้ามเซ็ต value ตรงๆ ใน build แบบนี้: statusCardController.isCardFrozen.value = ...
        if (!statusCardController.isLoading.value) {
          statusCardController.isCardFrozen.value = card['status'] != 'active';
        }
        return SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 20,
                ),
                child: _buildCard(card, ownerEn, Cardname),
              ),

              const Text(
                "รายละเอียดบัตร",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              _buildDetailSection([
                _buildRow("ชื่อ นามสกุล", homeController.fullNameTh.value),
                _buildRow(
                  "สถานะบัตร",
                  isCurrentlyFrozen ? "ปิดใช้งาน" : "เปิดใช้งาน",
                  valueColor: isCurrentlyFrozen ? Colors.red : Colors.green,
                ),
                _buildRow("ผูกกับบัญชี", homeController.accountNumber.value),
                InkWell(
                  // ตรวจสอบเงื่อนไข: ถ้าเป็นบัตร Physical และสถานะ inactive จะให้ onTap เป็น null (กดไม่ได้)
                  onTap:
                      (card['virtual'] == false && card['status'] == 'inactive')
                      ? null
                      : () => Get.toNamed(
                          '/pin_verify_page',
                          arguments: {
                            'action': 'view_sensitive',
                            'card': card,
                            'card_id': card['card_id'],
                            'ownerName': ownerEn,
                          },
                        ),
                  child: _buildRow(
                    "ดูเลขบัตร",
                    (card['virtual'] == false && card['status'] == 'inactive')
                        ? "ต้องเปิดใช้งานก่อน"
                        : "",
                    // ถ้ากดไม่ได้ อาจจะซ่อนลูกศรด้วยเพื่อสื่อสารกับผู้ใช้ว่ากดไม่ได้
                    showArrow:
                        !(card['virtual'] == false &&
                            card['status'] == 'inactive'),
                  ),
                ),
              ]),
              _buildSectionHeader("วงเงิน"),
              _buildDetailSection([
                _buildRow(
                  "วงเงินปัจจุบัน",
                  "${card['current_spending_limit'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} บาท",
                  isBoldValue: true,
                ),
                InkWell(
                  onTap: () => Get.toNamed(
                    '/change_limit_card',
                    arguments: {'card': card, 'ownerName': ownerEn},
                  ),
                  child: _buildRow("ปรับวงเงิน", "", showArrow: true),
                ),
              ]),

              _buildSectionHeader("ความปลอดภัย"),
              _buildDetailSection([
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 15,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "เปิดใช้งานบัตร",
                        style: TextStyle(fontSize: 16),
                      ),
                      Switch(
                        value: !statusCardController
                            .isCardFrozen
                            .value, // active = !frozen
                        onChanged: (val) {
                          if (val) {
                            statusCardController.unfreezeCard(currentCardId);
                          } else {
                            statusCardController.freezeCard(currentCardId);
                          }
                        },
                        activeColor: const Color(0xFF264FAD),
                      ),
                    ],
                  ),
                ),
              ]),
              if ((card['is_physical_requested'] == false &&
                      card['virtual'] == true) ||
                  (card['virtual'] == false && card['status'] == 'inactive'))
                _buildSectionHeader("บัตร Physical"),

              _buildDetailSection([
                if (card['virtual'] == true &&
                    card['is_physical_requested'] == false)
                  InkWell(
                    onTap: () => Get.toNamed(
                      '/requestPhysical',
                      arguments: {
                        'action': 'view_sensitive_for_activate',
                        'card': card,
                        'ownerName': ownerEn,
                      },
                    ),
                    child: _buildRow("ขอบัตร Physical", "", showArrow: true),
                  ),
                if (card['virtual'] == false &&
                    card['status'] == 'inactive' &&
                    detailController.trackingData['delivery_status'] ==
                        'success')
                  InkWell(
                    onTap: () => Get.toNamed(
                      '/activate_physical',
                      arguments: {'card': card, 'ownerName': ownerEn},
                    ),
                    child: _buildRow(
                      "เปิดใช้งานบัตร Physical",
                      "",
                      showArrow: true,
                    ),
                  ),
              ]),

              if (card['virtual'] == false && card['status'] == 'inactive') ...[
                _buildDetailSection([
                  _buildRow(
                    "สถานะปัจจุบัน",
                    // ✅ ดึงข้อมูลสถานะจาก trackingData เช่น "กำลังจัดส่ง" หรือ "เตรียมจัดส่ง"
                    detailController.trackingData['delivery_status'] ??
                        "กำลังเตรียมการจัดส่ง",
                    valueColor: Colors.blueAccent,
                    isBoldValue: true,
                  ),
                ]),
              ],
              const SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }

  // ฟังก์ชันวาดหน้าบัตร โดยรองรับรูปภาพ Base64 จาก API
  Widget _buildCard(dynamic card, String name, String cardname) {
    return Container(
      height: 190,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        // ✅ แสดงรูปภาพจริงที่ได้จาก API (ถ้ามี)
        image: card['card_image'] != null
            ? DecorationImage(
                image: MemoryImage(base64Decode(card['card_image'])),
                fit: BoxFit.cover,
              )
            : null,
        gradient: card['card_image'] == null
            ? const LinearGradient(
                colors: [Color(0xFF3B5BDB), Color(0xFF162E7A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              cardname.toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 5),
                Text(
                  "**** **** **** ${card['last_digits']}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  card['virtual'] == true ? "Virtual Card" : "Physical Card",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Image.network(
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Mastercard-logo.svg/1280px-Mastercard-logo.svg.png',
                  width: 40,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 15, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildDetailSection(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildRow(
    String label,
    String value, {
    Color? valueColor,
    bool showArrow = false,
    bool isBoldValue = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF595858), fontSize: 14),
          ),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isBoldValue ? FontWeight.bold : FontWeight.normal,
                  color: valueColor ?? Colors.black87,
                ),
              ),
              if (showArrow)
                const Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
