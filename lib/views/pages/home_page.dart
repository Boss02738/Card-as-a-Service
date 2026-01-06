import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/module/controller/my_cards_controller.dart';

import 'package:my_app/views/widgets/buildHeader.dart';
import 'package:my_app/views/widgets/custom_bottom_nav_bar.dart';
import 'package:my_app/views/widgets/gradient_header.dart';
import 'package:my_app/module/controller/home_controller.dart'; // import controller

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.put(HomeController());
    final MyCardsController cardController = Get.put(MyCardsController());
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          const GradientHeader(),
          SafeArea(
            child: Obx(() {
              // ถ้ากำลังโหลด ให้โชว์ Loading
              if (homeController.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Buildheader(),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: _buildAccount(homeController),
                    ),
                    const SizedBox(height: 10),
                    _buildOffersSection(), // ส่วนข้อเสนอพิเศษ
                    const SizedBox(height: 10),
                    _buildMyCardsSection(
                      cardController,
                      homeController, // ส่วนบัตรของฉัน0.
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          if (index == 1) {
            Get.toNamed('/account');
          } else if (index == 2) {
            Get.toNamed('/my_cards');
          }
        },
      ),
    );
  }

  // account
  Widget _buildAccount(HomeController homeController) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: AssetImage('assets/images/account_banner.png'),
          fit: BoxFit.cover, // ให้รูปภาพขยายเต็มพื้นที่ Container
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, // กระจายเนื้อหาให้สวยงาม
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                homeController.fullNameTh.value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                homeController.accountType.value,
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // แสดงเลขบัญชีแบบ Mask
              Text(
                homeController.accountNumber.value.length > 4
                    ? "xxx-x-xx${homeController.accountNumber.value.replaceAll('-', '').substring(homeController.accountNumber.value.replaceAll('-', '').length - 4)}"
                    : homeController.accountNumber.value,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 15),
              const Text(
                "ยอดเงินคงเหลือ (บาท)",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              // ยอดเงิน (Format ให้มีคอมม่า)
              Text(
                homeController.balance.value
                    .toStringAsFixed(2)
                    .replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]},',
                    ),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// กล่องแสดงผลเมื่อยังไม่มีบัตร (Empty State)
Widget _buildEmptyCardSlot() {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(horizontal: 15),
    height: 160,
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.05), // พื้นหลังจางๆ แบบ Glassmorphism
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white12),
    ),
    child: InkWell(
      onTap: () => Get.toNamed('/type_cards'), // กดแล้วไปหน้าสมัครบัตร
      borderRadius: BorderRadius.circular(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_rounded,
              color: Colors.blueAccent,
              size: 30,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'สมัครบัตรเดบิต',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'จัดการบัตรและสิทธิพิเศษมากมาย',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    ),
  );
}

Widget _buildOffersSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'ข้อเสนอพิเศษ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(
              onPressed: () => Get.toNamed('/my_cards'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 169, 169, 169).withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 0,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'ดูทั้งหมด',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      fontSize: 14,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: const Color.fromARGB(
                      255,
                      255,
                      255,
                      255,
                    ).withOpacity(0.7),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      SizedBox(
        height: 160,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          children: [
            // ✅ กำหนดให้ promo1 กดแล้วไปหน้า /type_cards
            _buildOfferItem(
              'assets/images/promo1.png',
              onTap: () => Get.toNamed('/type_cards'),
            ),
            // รูปอื่นๆ (ถ้ายังไม่มี action ให้ใส่ค่าว่างไว้ก่อน)
            _buildOfferItem('assets/images/promo2.png', onTap: () {}),
          ],
        ),
      ),
    ],
  );
}

Widget _buildOfferItem(String imagePath, {required VoidCallback onTap}) {
  return InkWell(
    onTap: onTap, //  รับค่า Action มาทำงาน
    borderRadius: BorderRadius.circular(15),
    child: Container(
      width: 250,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
      ),
    ),
  );
}

/////////////////////////////////////////////////////////////////////////////////////////
// เพิ่ม Widget ส่วน 'บัตรของฉัน' โดยรับ controller เข้ามาตรวจสอบ
Widget _buildMyCardsSection(
  MyCardsController cardController,
  HomeController homeController,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'บัตรของฉัน',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(
              onPressed: () => Get.toNamed('/my_cards'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 169, 169, 169).withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 0,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'ดูทั้งหมด',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      fontSize: 14,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: const Color.fromARGB(
                      255,
                      255,
                      255,
                      255,
                    ).withOpacity(0.7),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      Obx(() {
        if (cardController.myCards.isEmpty) {
          return _buildEmptyCardSlot();
        } else {
          return SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              itemCount: cardController.myCards.length,
              itemBuilder: (context, index) {
                // ส่งชื่อภาษาอังกฤษจาก homeController ไปแสดงบนหน้าบัตร
                return _buildActiveCardItem(
                  cardController.myCards[index],
                  homeController.fullNameEn.value, // ดึงชื่อภาษาอังกฤษ
                );
              },
            ),
          );
        }
      }),
    ],
  );
}

Widget _buildActiveCardItem(dynamic card, String ownerName) {
  return Container(
    width: 300,
    margin: const EdgeInsets.only(right: 15),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: const LinearGradient(
        colors: [
          Color(0xFF264FAD),
          Color(0xFF162E7A),
        ], // ใช้โทนสีน้ำเงินตามรูปบัตร
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black38,
          blurRadius: 8,
          offset: const Offset(0, 4),
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
            Text(
              card['type_debit_name'] ?? 'Virtual Card',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const Spacer(),
        Text(
          ownerName.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5),
        // ✅ แสดงเลขบัตรที่ Mask ไว้ (ดึง last_digits จาก API)
        Text(
          '**** **** **** ${card['last_digits'] ?? '****'}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Virtual Card',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
                          Image.network(
                'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Mastercard-logo.svg/1280px-Mastercard-logo.svg.png',
                width: 30,
              ),
          ],
        ),
      ],
    ),
  );
}
