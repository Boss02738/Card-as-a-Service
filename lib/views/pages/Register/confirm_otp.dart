import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:my_app/module/controller/header_text_controller.dart';
import 'package:my_app/module/controller/phonenumber_controller.dart';
import 'package:my_app/views/widgets/data_card.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/header_texts.dart';
import '../../widgets/arrow_fab.dart';
import 'dart:async';

class Confirm_otp extends StatefulWidget {
  const Confirm_otp({super.key});

  @override
  State<Confirm_otp> createState() => _Confirm_otpState();
}

class _Confirm_otpState extends State<Confirm_otp> {
  final _otpCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Timer? _cooldownTimer;
  final RxInt cooldown = 0.obs; // วินาทีที่เหลือ
  final ValueNotifier<bool> isOtpComplete = ValueNotifier(false);

  final PhonenumberController phonenumberController =
      Get.find<PhonenumberController>();
  final HeaderTextController headerTextController =
      Get.find<HeaderTextController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      headerTextController.setHeaderText(
        'กรอกรหัสยืนยัน OTP',
        'รหัสส่งไปที่เบอร์: ${phonenumberController.phoneNumber.value}',
      );
    });
  }

  @override
  void dispose() {
    _otpCtrl.dispose();
    _cooldownTimer?.cancel();
    isOtpComplete.dispose(); // ล้างหน่วยความจำ
    super.dispose();
  }

  void _onConfirm() {
    if (_formKey.currentState!.validate()) {
      Get.offNamed(
        '/user_selection',
        arguments: {'verifiedMobile': phonenumberController.phoneNumber.value},
      )?.then((value) {
        headerTextController.setHeaderText(
          'กรอกรหัสยืนยัน OTP',
          'รหัสส่งไปที่เบอร์: ${phonenumberController.phoneNumber.value}',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ดีไซน์กล่อง OTP แบบ Responsive
    final defaultPinTheme = PinTheme(
      width: 52.w,
      height: 60.h,
      textStyle: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(8.r),
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          const GradientHeader(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 30.h),
                const BrandLogo(),
                SizedBox(height: 30.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 22.w),
                  child: const HeaderTexts(),
                ),
                SizedBox(height: 20.h),
                Expanded(
                  child: DataCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16.h),
                          _buildOtpHeader(), // แยกส่วน Header ของฟอร์ม
                          SizedBox(height: 24.h),

                          Center(
                            child: Pinput(
                              length: 6,
                              controller: _otpCtrl,
                              // ✅ เมื่อมีการกรอก ให้เช็คความยาวเพื่อเปิด/ปิดปุ่ม
                              onChanged: (value) {
                                isOtpComplete.value = value.length == 6;
                              },
                              focusedPinTheme: defaultPinTheme.copyWith(
                                decoration: defaultPinTheme.decoration!
                                    .copyWith(
                                      border: Border.all(
                                        color: const Color(0xFF2D56BB),
                                      ),
                                    ),
                              ),
                              errorPinTheme: defaultPinTheme.copyWith(
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.05),
                                  border: Border.all(color: Colors.redAccent),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'กรุณากรอกรหัส OTP';
                                if (value.length < 6)
                                  return 'รหัสไม่ครบ 6 หลัก';
                                return null;
                              },
                            ),
                          ),

                          const Spacer(),

                          // ส่วนของปุ่มยืนยันที่เปลี่ยนสีตามสถานะ
                          ValueListenableBuilder<bool>(
                            valueListenable: isOtpComplete,
                            builder: (context, otpValid, child) {
                              return Obx(() {
                                // ต้องกรอกครบ 6 หลัก และไม่ได้กำลังโหลด API
                                bool canSubmit =
                                    otpValid &&
                                    !phonenumberController.isLoading.value;

                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      phonenumberController.isLoading.value
                                          ? 'กำลังตรวจสอบ...'
                                          : 'ยืนยัน',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        //  เปลี่ยนสีตัวอักษร: เทา (Disable) -> น้ำเงิน (Enable)
                                        color: canSubmit
                                            ? const Color.fromARGB(255, 0, 0, 0)
                                            : Colors.black.withOpacity(0.4),
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    ArrowFab(
                                      enabled: canSubmit,
                                      onPressed: canSubmit ? _onConfirm : () {},
                                    ),
                                  ],
                                );
                              });
                            },
                          ),
                          SizedBox(height: 16.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

Widget _buildOtpHeader() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Obx(() => Text(
        'เลขอ้างอิง: ${phonenumberController.REF_CODE.value}',
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
      )),

      Obx(() {
        final bool isCoolingDown = cooldown.value > 0;
        final bool isDisabled =
            isCoolingDown || phonenumberController.isLoading.value;

        return InkWell(
          onTap: isDisabled
              ? null
              : () {
                  phonenumberController.submitPhone();
                  // _startCooldown();
                },
          child: Row(
            children: [
              Icon(
                Icons.refresh,
                size: 20.r,
                color: isDisabled ? Colors.grey[400] : Colors.grey[600],
              ),
              SizedBox(width: 4.w),
              Text(
                isCoolingDown
                    ? 'ขอใหม่ได้ใน ${cooldown.value}s'
                    : 'ขอรหัสอีกครั้ง',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isDisabled ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      }),
    ],
  );
}


  void _startCooldown() {
    cooldown.value = 60;

    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (cooldown.value == 0) {
        timer.cancel();
      } else {
        cooldown.value--;
      }
    });
  }
}
