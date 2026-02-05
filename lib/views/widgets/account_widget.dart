import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart'; // อย่าลืม import get
import 'package:my_app/module/controller/home_controller.dart';

class AccountWidget extends StatelessWidget {
  const AccountWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.find<HomeController>();

    return Obx(
      () => AspectRatio(
        aspectRatio: 19 / 9, 
        child: Container(
          padding: EdgeInsets.all(20.r),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            image: const DecorationImage(
              image: AssetImage('assets/images/account_banner.png'),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10.r,
                offset: Offset(0, 5.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "คุณ ${homeController.fullNameTh.value}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
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

              const Spacer(),

              /// ACCOUNT INFO
              Text(
                homeController.accountNumber.value,
                style: TextStyle(color: Colors.white70, fontSize: 14.sp),
              ),
              SizedBox(height: 8.h),

              Text(
                "ยอดเงินคงเหลือ (บาท)",
                style: TextStyle(color: Colors.white70, fontSize: 12.sp),
              ),

              FittedBox(
                fit: BoxFit.scaleDown, // 🔥 ตัวกัน overflow ตัวจริง
                child: Text(
                  homeController.balance.value
                      .toStringAsFixed(2)
                      .replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (m) => '${m[1]},',
                      ),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
