import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_app/module/controller/mainTab_Controller%20.dart';
import 'package:my_app/views/widgets/buildHeader.dart';
import 'package:my_app/views/widgets/exit_confirmation_dialog.dart';
import 'package:my_app/views/widgets/gradient_header.dart';
import 'package:my_app/module/controller/home_controller.dart';
import 'package:my_app/module/controller/my_cards_controller.dart';
import 'package:my_app/views/widgets/account_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.put(HomeController());
    final MyCardsController cardController = Get.put(MyCardsController());
    return BackButtonInterceptor(
      child: Scaffold(
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
                      SizedBox(height: 10.h),
                      const Buildheader(),
                      SizedBox(height: 10.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.w),
                        child: const AccountWidget(),
                      ),
                      SizedBox(height: 10.h),
                      _buildOffersSection(), // ส่วนข้อเสนอพิเศษ
                      SizedBox(height: 10.h),
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
      ),
    );
  }
}

// กล่องแสดงผลเมื่อยังไม่มีบัตร (Empty State)
Widget _buildEmptyCardSlot() {
  return Container(
    width: double.infinity,
    margin: EdgeInsets.symmetric(horizontal: 15.w),
    height: 160.h,
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(20.r),
      border: Border.all(color: Colors.white12),
    ),
    child: InkWell(
      onTap: () => Get.toNamed('/type_cards'), 
      borderRadius: BorderRadius.circular(20.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add_rounded,
              color: Colors.blueAccent,
              size: 30.r,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'สมัครบัตรเดบิต',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'จัดการบัตรและสิทธิพิเศษมากมาย',
            style: TextStyle(color: Colors.white38, fontSize: 12.sp),
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
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ข้อเสนอพิเศษ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Get.find<MainTabController>().changeTab(2);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(
                  255,
                  169,
                  169,
                  169,
                ).withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 0.h),
              ),
              child: Row(
                children: [
                  Text(
                    'ดูทั้งหมด',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      fontSize: 14.sp,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12.r,
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
      SizedBox(height: 10.h),
      SizedBox(
        height: 180.h,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          children: [
            // กำหนดให้ promo1 กดแล้วไปหน้า /type_cards
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
    borderRadius: BorderRadius.circular(15.r),
    child: Container(
      width: 0.7.sw,
      margin: EdgeInsets.only(right: 15.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.r),
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
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'บัตรของฉัน',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Get.find<MainTabController>().changeTab(2);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(
                  255,
                  169,
                  169,
                  169,
                ).withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 0.h),
              ),
              child: Row(
                children: [
                  Text(
                    'ดูทั้งหมด',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      fontSize: 14.sp,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12.r,
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
      SizedBox(height: 12.h),
      Obx(() {
        if (cardController.myCards.isEmpty) {
          return _buildEmptyCardSlot();
        } else {
          return SizedBox(
            height: 170.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 15.w),
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
  return InkWell(
    onTap: () {
      Get.toNamed(
        '/my_card_detail',
        arguments: {'card_id': card['card_id'], 'ownerName': ownerName},
      );
    },
    child: Container(
      width: 300.w,
      margin: EdgeInsets.only(right: 15.r),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: const LinearGradient(
          colors: [Color(0xFF264FAD), Color(0xFF162E7A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 8.r,
            offset: Offset(0, 4.h),
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
                card['card_name'] ?? 'Novapay',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            ownerName.toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 5.h),
          // ✅ แสดงเลขบัตรที่ Mask ไว้ (ดึง last_digits จาก API)
          Text(
            '**** **** **** ${card['last_digits'] ?? '****'}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              letterSpacing: 2.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                card['virtual'] == true ? 'Virtual Card' : 'Physical Card',
                style: TextStyle(color: Colors.white70, fontSize: 11.sp),
              ),
              Image.network(
                'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Mastercard-logo.svg/1280px-Mastercard-logo.svg.png',
                width: 25.w,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
