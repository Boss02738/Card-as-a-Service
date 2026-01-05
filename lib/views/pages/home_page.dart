import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/module/controller/my_cards_controller.dart';
import 'package:my_app/views/widgets/brand_logo.dart';
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
    // ลงทะเบียนและดึง Controller
    // final HomeController controller = Get.put(HomeController());
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
                    _buildHeader(),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: _buildAccount(homeController),
                    ),
                    const SizedBox(height: 20),
                    _buildOffersSection(), // ส่วนข้อเสนอพิเศษ
                    const SizedBox(height: 20),
                    _buildMyCardsSection(
                      cardController,
                    ), // ส่วนบัตรของฉัน (ที่มีกล่องสมัครบัตร)
                    const SizedBox(height: 20),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 0, onTap: (i) {}),
    );
  }

  // account
  Widget _buildAccount(HomeController homeController) {
    return Container(
      // margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          Text(
            homeController.accountNumber.value,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 25),
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
    );
  }
}

// Header Widget
Widget _buildHeader() {
  return Stack(
    alignment: Alignment.center,
    children: [
      const Center(child: BrandLogo()),
      Positioned(
        left: 15,
        child: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.white.withOpacity(0.3),
          child: const Icon(Icons.person, color: Colors.white),
        ),
      ),
    ],
  );
}

// Widget สำหรับปุ่ม "ดูทั้งหมด" แบบ Figma
Widget _buildViewAllButton() {
  return TextButton(
    onPressed: () {},
    style: TextButton.styleFrom(
      backgroundColor: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
    ),
    child: Row(
      children: const [
        Text(
          'ดูทั้งหมด',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Icon(Icons.chevron_right, color: Colors.white70, size: 16),
      ],
    ),
  );
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
            _buildViewAllButton(),
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
            _buildOfferItem(
              'assets/images/promo2.png',
              onTap: () {},
            ),
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
        image: DecorationImage(
          image: AssetImage(imagePath), 
          fit: BoxFit.cover,
        ),
      ),
    ),
  );
}

/////////////////////////////////////////////////////////////////////////////////////////
// เพิ่ม Widget ส่วน 'บัตรของฉัน' โดยรับ controller เข้ามาตรวจสอบ
Widget _buildMyCardsSection(MyCardsController controller) {
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
            _buildViewAllButton(),
          ],
        ),
      ),
      const SizedBox(height: 12),

      // ✅ ตรวจสอบเงื่อนไขตรงนี้
      Obx(() {
        // สมมติว่าใน controller มีตัวแปร myCards เป็น List เก็บข้อมูลบัตร
        if (controller.myCards.isEmpty) {
          // ถ้าไม่มีบัตร แสดงกล่องสมัคร
          return _buildEmptyCardSlot();
        } else {
          // ถ้ามีบัตร แสดงรายการบัตร (ใช้ ListView แนวนอน)
          return SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              itemCount: controller.myCards.length,
              itemBuilder: (context, index) {
                return _buildActiveCardItem(controller.myCards[index]);
              },
            ),
          );
        }
      }),
    ],
  );
}

// Widget แสดงหน้าตาบัตรที่เรามีแล้ว
Widget _buildActiveCardItem(dynamic card) {
  return Container(
    width: 280,
    margin: const EdgeInsets.only(right: 15),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: const LinearGradient(
        colors: [Color(0xFF0F2027), Color(0xFF203A43)], // สีโทนบัตรเข้มๆ
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5)),
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
              card['type_debit_name'] ?? 'Debit Card',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Icon(Icons.contactless, color: Colors.white70, size: 20),
          ],
        ),
        Text(
          // ✅ แก้ไข: ดึงเลข 4 หลักสุดท้ายจาก API
          '**** **** **** ${card['last_digits'] ?? '****'}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            letterSpacing: 2,
          ),
        ),
      ],
    ),
  );
}
