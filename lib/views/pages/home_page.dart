import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_app/module/controller/main_tab_controller.dart';
import 'package:my_app/views/slidebar_promotion.dart';
import 'package:my_app/views/widgets/buildHeader.dart';
import 'package:my_app/views/widgets/debitcard.dart';
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
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: const AccountWidget(),
                      ),
                      SizedBox(height: 10.h),
                      _buildOffersSection(), // ส่วนข้อเสนอพิเศษ
                      // SizedBox(height: 10.h),
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
              onPressed: () => Get.toNamed('/promotion'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 0.h),
              ),
              child: Row(
                children: [
                  Text('ดูทั้งหมด', style: TextStyle(color: Colors.white, fontSize: 14.sp)),
                  Icon(Icons.arrow_forward_ios, size: 12.r, color: Colors.white.withOpacity(0.7)),
                ],
              ),
            ),
          ],
        ),
        
      ),
      SizedBox(height: 10.h),
      
      // 🚩 แก้ไขตรงนี้: นำ WebView Slider มาใส่แทน ListView เดิม
      const PromoSliderWebView(), 
      
      // หมายเหตุ: ไม่ต้องใช้ ListView(scrollDirection: Axis.horizontal) แล้ว 
      // เพราะใน PWA (Vue) จะทำหน้าที่สไลด์ด้วยตัวมันเองครับ
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
    child: Padding(
      padding: EdgeInsets.only(right: 15.w),
      // ✅ เปลี่ยนจาก Container เดิม มาใช้ BankCard Widget
      child: SizedBox(
        width: 300.w, // กำหนดความกว้างให้เท่าเดิม
        child: BankCard(
          card: card, // ส่ง Object 'card' ทั้งก้อนที่มีฟิลด์ 'card_image'
          ownerName: ownerName, cardName: card['card_name'] ?? '',
          // cardName: card['fddf'] ?? '',
        ),
      ),
    ),
  );
}
