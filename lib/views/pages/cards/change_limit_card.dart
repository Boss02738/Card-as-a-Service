import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  // ตัวแปรสำหรับเก็บค่าวงเงินที่เลือก
  String? selectedLimit;

  @override
  void initState() {
    super.initState();
    card = data['card'];
    ownerName = data['ownerName'];
    // กำหนดค่าเริ่มต้นตามวงเงินปัจจุบันจาก API
    double currentLimit = (card['current_spending_limit'] as num).toDouble();
    selectedLimit = currentLimit.toInt().toString();
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
          // 2. ส่วนแสดงรูปบัตร (ใช้ดีไซน์เดียวกับหน้า Detail)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            // decoration: const BoxDecoration(
            //   color: Color(0xFF264FAD),
            //   borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            // ),
            child: _buildCard(card, ownerName),
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

                  const Spacer(),

                  // 4. ปุ่มบันทึกด้านล่าง
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {

                        Get.back();
                        Get.snackbar(
                          "สำเร็จ",
                          "ปรับเปลี่ยนวงเงินเรียบร้อยแล้ว",
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF264FAD),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "บันทึก",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              const Text(
                "Virtual Card",
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
