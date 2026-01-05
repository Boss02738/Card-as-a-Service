import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/module/controller/my_cards_controller.dart';
import 'package:my_app/module/controller/home_controller.dart';
import 'package:my_app/views/widgets/buildHeader.dart';
import 'package:my_app/views/widgets/custom_bottom_nav_bar.dart';
import 'package:my_app/views/widgets/gradient_header.dart';

class MyCardPage extends StatefulWidget {
  const MyCardPage({super.key});

  @override
  State<MyCardPage> createState() => _MyCardPageState();
}

class _MyCardPageState extends State<MyCardPage> {
  int _selectedIndex = 2;

  @override
  Widget build(BuildContext context) {
    // ดึง Controller มาใช้งาน
    final MyCardsController cardController = Get.find<MyCardsController>();
    final HomeController homeController = Get.find<HomeController>();

    return DefaultTabController(
      length: 3, // ทั้งหมด, เปิดใช้งาน, ระงับชั่วคราว
      child: Scaffold(
        body: Stack(
          children: [
            const GradientHeader(),
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Buildheader(),
                  const SizedBox(height: 20),
                  
                  // ส่วนของ TabBar และรายการบัตร
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(220, 255, 255, 255),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          // TabBar ตามดีไซน์
                          const TabBar(
                            indicatorColor: Color(0xFF264FAD),
                            labelColor: Color(0xFF264FAD),
                            unselectedLabelColor: Colors.grey,
                            indicatorSize: TabBarIndicatorSize.label,
                            tabs: [
                              Tab(text: 'ทั้งหมด'),
                              Tab(text: 'เปิดใช้งาน'),
                              Tab(text: 'ระงับชั่วคราว'),
                            ],
                          ),
                          const SizedBox(height: 15),
                          
                          // แสดงรายการบัตรตามสถานะ
                          Expanded(
                            child: TabBarView(
                              children: [
                                // Tab: ทั้งหมด
                                Obx(() => _buildCardList(cardController.myCards, homeController.fullNameEn.value)),
                                // Tab: เปิดใช้งาน
                                Obx(() => _buildCardList(
                                  cardController.myCards.where((c) => c['status'] == 'active').toList(), 
                                  homeController.fullNameEn.value
                                )),
                                // Tab: ระงับชั่วคราว (สมมติ status คือ 'inactive' หรือ 'hold')
                                Obx(() => _buildCardList(
                                  cardController.myCards.where((c) => c['status'] != 'active').toList(), 
                                  homeController.fullNameEn.value
                                )),
                              ],
                            ),
                          ),
                          
                          // ปุ่มสมัครบัตรด้านล่าง
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () => Get.toNamed('/type_cards'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF264FAD),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text('สมัครบัตรเดบิต', style: TextStyle(color: Colors.white, fontSize: 18)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 80), // เว้นที่ให้ NavBar
                ],
              ),
            ),
            
            // NavBar อยู่ด้านล่างสุด
            Align(
              alignment: Alignment.bottomCenter,
              child: CustomBottomNavBar(
                currentIndex: _selectedIndex,
                onTap: (index) {
                  setState(() => _selectedIndex = index);
                  if (index == 0) Get.toNamed('/home');
                  if (index == 1) Get.toNamed('/account');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ฟังก์ชันสร้างรายการบัตรแบบแนวตั้ง (เหมือนในรูป image_9acc24.png)
  Widget _buildCardList(List<dynamic> cards, String ownerName) {
    if (cards.isEmpty) return const Center(child: Text("ไม่มีข้อมูลบัตร"));

    return ListView.builder(
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: _buildVerticalCardItem(card, ownerName),
        );
      },
    );
  }

  Widget _buildVerticalCardItem(dynamic card, String ownerName) {
    bool isActive = card['status'] == 'active'; // เช็คสถานะจาก API

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF264FAD), Color(0xFF162E7A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("NovaPay", style: TextStyle(color: Colors.white, fontSize: 18)),
              // ป้ายสถานะ (Badge)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  isActive ? "เปิดใช้งาน" : "ระงับชั่วคราว",
                  style: TextStyle(color: isActive ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Text(ownerName.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 14)),
          const SizedBox(height: 5),
          Text(
            '**** **** **** ${card['last_digits'] ?? '****'}', // ดึงเลขท้ายจาก API
            style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 2),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                card['virtual'] == "true" ? "Virtual Card" : "Physical Card",
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Image.network(
                'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Mastercard-logo.svg/1280px-Mastercard-logo.svg.png',
                width: 35,
              ),
            ],
          ),
        ],
      ),
    );
  }
}