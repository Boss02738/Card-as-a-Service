import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_app/module/controller/my_cards_controller.dart';
import 'package:my_app/module/controller/home_controller.dart';
import 'package:my_app/views/widgets/buildHeader.dart';
import 'package:my_app/views/widgets/exit_confirmation_dialog.dart';
import 'package:my_app/views/widgets/gradient_header.dart';

class MyCardPage extends StatefulWidget {
  const MyCardPage({super.key});

  @override
  State<MyCardPage> createState() => _MyCardPageState();
}

class _MyCardPageState extends State<MyCardPage> {
  @override
  Widget build(BuildContext context) {
    // ดึง Controller มาใช้งาน
    final MyCardsController cardController = Get.find<MyCardsController>();
    final HomeController homeController = Get.find<HomeController>();

    return BackButtonInterceptor(
      child: DefaultTabController(
        length: 3, // ทั้งหมด, เปิดใช้งาน, ระงับชั่วคราว
        child: Scaffold(
          body: Stack(
            children: [
              const GradientHeader(),
              SafeArea(
                child: Column(
                  children: [
                     SizedBox(height: 10.h),
                     Buildheader(),
                     SizedBox(height: 10.h),
      
                    // ส่วนของ TabBar และรายการบัตร
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 15.w),
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(220, 255, 255, 255),
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                        child: Column(
                          children: [
                            // TabBar
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
                             SizedBox(height: 15.h),
      
                            // แสดงรายการบัตรตามสถานะ
                            Expanded(
                              child: TabBarView(
                                children: [
                                  // Tab: ทั้งหมด
                                  Obx(
                                    () => _buildCardList(
                                      cardController.myCards,
                                      homeController.fullNameEn.value,
                                    ),
                                  ),
                                  // Tab: เปิดใช้งาน
                                  Obx(
                                    () => _buildCardList(
                                      cardController.myCards
                                          .where((c) => c['status'] == 'active')
                                          .toList(),
                                      homeController.fullNameEn.value,
                                    ),
                                  ),
                                  // Tab: ระงับชั่วคราว (สมมติ status คือ 'inactive' หรือ 'hold')
                                  Obx(
                                    () => _buildCardList(
                                      cardController.myCards
                                          .where((c) => c['status'] != 'active')
                                          .toList(),
                                      homeController.fullNameEn.value,
                                    ),
                                  ),
                                ],
                              ),
                            ),
      
                            // ปุ่มสมัครบัตรด้านล่าง
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              child: SizedBox(
                                width: double.infinity,
                                height: 50.h,
                                child: ElevatedButton(
                                  onPressed: () => Get.toNamed('/type_cards'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF264FAD),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                  ),
                                  child: Text(
                                    'สมัครบัตรเดบิต',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                     SizedBox(height: 10.h), // เว้นที่ให้ NavBar
                  ],
                ),
              ),
      
              // NavBar อยู่ด้านล่างสุด

            ],
          ),
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
        return InkWell(
          onTap: () {
            Get.toNamed(
              '/my_card_detail',
              arguments: {'card_id': card['card_id']},
            );
          },
          child: Padding(
            padding: EdgeInsets.only(bottom: 15.h),
            child: _buildVerticalCardItem(card, ownerName),
          ),
        );
      },
    );
  }

  Widget _buildVerticalCardItem(dynamic card, String ownerName) {
    bool isActive = card['status'] == 'active'; // เช็คสถานะจาก API

    return Container(
      padding:  EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
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
               Text(
                card['card_name'] ?? 'Novapay',
                style: TextStyle(color: Colors.white, fontSize: 18.sp),
              ),
              // ป้ายสถานะ (Badge)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  isActive ? "เปิดใช้งาน" : "ระงับชั่วคราว",
                  style: TextStyle(
                    color: isActive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ],
          ),
         SizedBox(height: 40.h),
          Text(
            ownerName.toUpperCase(),
            style: TextStyle(color: Colors.white, fontSize: 14.sp),
          ),
           SizedBox(height: 5.h),
          Text(
            '**** **** **** ${card['last_digits'] ?? '****'}', // ดึงเลขท้ายจาก API
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              letterSpacing: 2,
            ),
          ),
         SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                card['virtual'] == true ? "Virtual Card" : "Physical Card",
                style: TextStyle(color: Colors.white70, fontSize: 12.sp),
              ),
              Image.network(
                'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Mastercard-logo.svg/1280px-Mastercard-logo.svg.png',
                width: 35.w,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
