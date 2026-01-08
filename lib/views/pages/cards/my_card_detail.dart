import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/module/controller/home_controller.dart';
import 'package:my_app/module/controller/my_cards_controller.dart';
import 'package:my_app/module/controller/status_card_controller.dart';

class MyCardDetail extends StatelessWidget {
  const MyCardDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final dynamic data = Get.arguments;
    final dynamic card = data['card'];
    final String ownerEn = data['ownerName'];
    final HomeController homeController = Get.find<HomeController>();
    final StatusCardController statusCardController = Get.put(
      StatusCardController(),
    );
    final String currentCardId = card['card_id'];

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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),

              child: _buildCard(card, ownerEn),
            ),

            const SizedBox(height: 20),

            // 2. Card Information Section
            Column(
              children: [
                Center(
                  child: const Text(
                    "รายละเอียดบัตร",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Obx(() {
              // ✅ ดึงข้อมูลบัตรใบนี้จาก Controller หลักที่อัปเดตแล้ว
              final latestCard = Get.find<MyCardsController>().myCards
                  .firstWhere(
                    (c) => c['card_id'] == currentCardId,
                    orElse: () => card,
                  );

              bool isCurrentlyFrozen = latestCard['status'] != 'active';
              // อัปเดตค่าใน status controller ให้ตรงกับความจริงล่าสุด
              statusCardController.isCardFrozen.value = isCurrentlyFrozen;

              return _buildDetailSection([
                _buildRow("ชื่อ นามสกุล", ownerEn),
                _buildRow(
                  "สถานะบัตร",
                  isCurrentlyFrozen ? "ปิดใช้งาน" : "เปิดใช้งาน",
                  valueColor: isCurrentlyFrozen ? Colors.red : Colors.green,
                ),
                _buildRow("ผูกกับบัญชี", homeController.accountNumber.value),
                InkWell(
                  onTap: () {
                    Get.toNamed(
                      '/pin_verify_page',
                      // ส่ง latestCard ไปเพื่อให้หน้าปรับวงเงินเห็นยอดล่าสุดด้วย
                      arguments: {
                        'action': 'view_sensitive',
                        'card': latestCard,
                        'ownerName': ownerEn,
                      },
                    );
                  },
                  child: _buildRow("ดูเลขบัตร", "", showArrow: true),
                ),
              ]);
            }),

            _buildSectionHeader("วงเงิน"),
            Obx(() {
              // ✅ ดึงข้อมูลล่าสุดจาก Controller เพื่อให้ยอดวงเงินอัปเดตทันที
              final latestCard = Get.find<MyCardsController>().myCards
                  .firstWhere(
                    (c) => c['card_id'] == currentCardId,
                    orElse: () => card,
                  );

              return _buildDetailSection([
                _buildRow(
                  "วงเงินปัจจุบัน",
                  // ✅ ใช้ข้อมูลจาก latestCard แทน card ปกติ
                  "${latestCard['current_spending_limit'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}0 บาท",
                  isBoldValue: true,
                ),
                InkWell(
                  onTap: () {
                    Get.toNamed(
                      '/change_limit_card',
                      // ส่ง latestCard ไปเพื่อให้หน้าปรับวงเงินเห็นยอดล่าสุดด้วย
                      arguments: {'card': latestCard, 'ownerName': ownerEn},
                    );
                  },
                  child: _buildRow("ปรับวงเงิน", "", showArrow: true),
                ),
              ]);
            }),

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
                    Obx(
                      () => Switch(
                        value: !statusCardController
                            .isCardFrozen
                            .value, // active = !frozen
                        onChanged: (val) {
                          if (val) {
                            statusCardController.unfreezeCard(card['card_id']);
                          } else {
                            statusCardController.freezeCard(card['card_id']);
                          }
                        },
                        activeColor: const Color(0xFF264FAD),
                      ),
                    ),
                  ],
                ),
              ),
            ]),

            // 5. Physical Card Section
            _buildSectionHeader("บัตร Physical"),
            _buildDetailSection([
              _buildRow("ขอบัตร Physical", "", showArrow: true),
              _buildRow("เปิดใช้งานบัตร Physical", "", showArrow: true),
            ]),

            Obx(
              () => statusCardController.isLoading.value
                  ? Container(
                      color: Colors.black26,
                      child: const Center(child: CircularProgressIndicator()),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  // Card Component
  Widget _buildCard(dynamic card, String name) {
    return Container(
      height: 190,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF3B5BDB), Color(0xFF162E7A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Novapay",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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
                card['virtual'] == "true" ? "Virtual Card" : "Physical Card",
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Image.network(
                'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Mastercard-logo.svg/1280px-Mastercard-logo.svg.png',
                width: 40,
              ),
            ],
          ),
        ],
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
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
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
            style: const TextStyle(
              color: Color.fromARGB(255, 89, 88, 88),
              fontSize: 14,
            ),
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
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
