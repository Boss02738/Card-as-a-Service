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
  // ประกาศ Controller ไว้ระดับคลาสเพื่อให้เรียกใช้ใน _onRefresh ได้สะดวก
  final HomeController homeController = Get.put(HomeController());
  final MyCardsController cardController = Get.put(MyCardsController());

  // ✅ ฟังก์ชันสำหรับดึงข้อมูลใหม่เมื่อ Pull-to-Refresh
  Future<void> _onRefresh() async {
    try {
      // สั่งให้ทั้ง 2 Controller โหลดข้อมูลใหม่พร้อมกัน
      await Future.wait([
        homeController.fetchHomeProfile(), 
        cardController.fetchMyCards(),    
      ]);
    } catch (e) {
      debugPrint("Refresh Error: $e");
    }
  }
  @override
  Widget build(BuildContext context) {
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

                // ✅ เพิ่ม RefreshIndicator ครอบ SingleChildScrollView
                return RefreshIndicator(
                  color: const Color(0xFF264FAD),
                  backgroundColor: Colors.white,
                  onRefresh: _onRefresh,
                  child: SingleChildScrollView(
                    // ✅ ใส่ physics เพื่อให้ดึงรีเฟรชได้เสมอแม้เนื้อหาไม่เต็มจอ
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
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
                        SizedBox(height: 15.h),
                        _buildOffersSection(), 
                        _buildMyCardsSection(
                          cardController,
                          homeController,
                        ),
                        // เพิ่มพื้นที่ด้านล่างเล็กน้อยให้ดึงง่ายขึ้น
                        SizedBox(height: 40.h),
                      ],
                    ),
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

// --- Widget ส่วนเสริมด้านล่างคงเดิม ---

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
      const PromoSliderWebView(), 
    ],
  );
}

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
                backgroundColor: Colors.white.withOpacity(0.1),
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
                      color: Colors.white,
                      fontSize: 14.sp,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12.r,
                    color: Colors.white.withOpacity(0.7),
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
                return _buildActiveCardItem(
                  cardController.myCards[index],
                  homeController.fullNameEn.value,
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
      child: SizedBox(
        width: 280.w,
        child: BankCard(
          card: card, 
          ownerName: ownerName, 
          cardName: card['card_name'] ?? '',
        ),
      ),
    ),
  );
}