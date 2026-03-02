import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_app/module/controller/home_controller.dart';
import 'package:my_app/views/widgets/account_widget.dart';
import 'package:my_app/views/widgets/buildHeader.dart';
import 'package:my_app/views/widgets/exit_confirmation_dialog.dart';
import 'package:my_app/views/widgets/gradient_header.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final HomeController homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return BackButtonInterceptor(
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA), // เพิ่มสีพื้นหลังให้เนียนกับหน้า Home
        body: Stack(
          children: [
            const GradientHeader(),
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 10.h),
                    const Buildheader(),
                    SizedBox(height: 10.h),
                    
                    // ✅ ปรับ Padding เป็น 10.w ให้เท่ากับหน้า HomePage
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: const AccountWidget(),
                    ),
                    
                    SizedBox(height: 20.h),
                    
                    // ✅ ปรับขอบข้างของ Card ข้อมูลให้เป็น 10.w เท่ากัน
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.w),
                      child: Container(
                        width: double.infinity,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10.r,
                              offset: Offset(0, 5.h),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // ส่วน Header ภายในการ์ด (Gradient)
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 20.h),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF3B5BDB),
                                    Color(0xFF162E7A),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Obx(() => Text(
                                    "คุณ ${homeController.fullNameTh.value}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )),
                                  SizedBox(height: 4.h),
                                  Obx(() => Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        homeController.accountType.value,
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        homeController.accountNumber.value,
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                    ],
                                  )),
                                ],
                              ),
                            ),
                            
                            // ส่วนรายละเอียดข้อมูลบัญชี
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                              child: Obx(() => Column(
                                children: [
                                  _buildRow(
                                    'ชื่อบัญชี',
                                    "คุณ ${homeController.fullNameTh.value}",
                                  ),
                                  _buildRow(
                                    'ประเภทบัญชี',
                                    homeController.accountType.value,
                                  ),
                                  _buildRow('อัตราดอกเบี้ย (%)', '0.25'),
                                  _buildRow(
                                    'วันที่เปิดบัญชี',
                                    homeController.createdAt.value,
                                  ),
                                  SizedBox(height: 10.h),
                                  _buildRow(
                                    'ยอดเงินคงเหลือ',
                                    homeController.balance.value
                                        .toStringAsFixed(2)
                                        .replaceAllMapped(
                                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                          (Match m) => '${m[1]},',
                                        ),
                                    isBoldValue: true,
                                  ),
                                  _buildRow(
                                    'ยอดเงินที่ใช้ได้',
                                    homeController.balance.value
                                        .toStringAsFixed(2)
                                        .replaceAllMapped(
                                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                          (Match m) => '${m[1]},',
                                        ),
                                    isBoldValue: true,
                                    valueColor: const Color(0xFF162E7A),
                                  ),
                                ],
                              )),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 30.h), // ระยะเผื่อด้านล่าง
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBoldValue = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: const Color(0xFFF0F0F0), width: 1.w),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFF666666),
              fontSize: 14.sp,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: isBoldValue ? FontWeight.bold : FontWeight.normal,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}