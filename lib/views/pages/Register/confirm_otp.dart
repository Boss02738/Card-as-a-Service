import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/views/pages/Register/idcard_verify.dart';
import 'package:pinput/pinput.dart';
import 'package:my_app/module/controller/header_text_controller.dart';
import 'package:my_app/module/controller/phonenumber_controller.dart';
import 'package:my_app/views/widgets/data_card.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/header_texts.dart';
import '../../widgets/arrow_fab.dart';

class Confirm_otp extends StatefulWidget {
  const Confirm_otp({super.key});

  @override
  State<Confirm_otp> createState() => _Confirm_otpState();
}

class _Confirm_otpState extends State<Confirm_otp> {
  final _otpCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final PhonenumberController phonenumberController =
      Get.find<PhonenumberController>();

  final HeaderTextController headerTextController =
      Get.find<HeaderTextController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final HeaderTextController headerTextController =
          Get.find<HeaderTextController>();
      headerTextController.setHeaderText(
        'กรอกรหัสยืนยัน OTP',
        'รหัสส่งไปที่เบอร์: ${phonenumberController.phoneNumber.value}',
      );
    });
  }

  @override
  void dispose() {
    _otpCtrl.dispose();
    super.dispose();
  }

  void _onConfirm() {
    if (_formKey.currentState!.validate()) {
      Get.offNamed('/user_selection')?.then((value) {
        // ล้างค่าเมื่อย้อนกลับมาถึงหน้าเดิม
        headerTextController.setHeaderText(
          'กรอกรหัสยืนยัน OTP',
          'รหัสส่งไปที่เบอร์: ${phonenumberController.phoneNumber.value}',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // กำหนดดีไซน์ของกล่อง OTP
    final defaultPinTheme = PinTheme(
      width: 45,
      height: 50,
      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          const GradientHeader(),
          Center(
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  const BrandLogo(),
                  const SizedBox(height: 30),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 22),
                    child: HeaderTexts(),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: DataCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Obx(
                                  () => Text(
                                    'เลขอ้างอิง: ${phonenumberController.refCode.value}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      // color: Colors.blue[900],
                                    ),
                                  ),
                                ),
                                InkWell(
                                  // เปลี่ยนเป็น InkWell เพื่อให้กด "ขอรหัสอีกครั้ง" ได้
                                  onTap: () {
                                    // Logic สำหรับขอ OTP ใหม่
                                    if (!phonenumberController
                                        .isLoading
                                        .value) {
                                      phonenumberController.submitPhone();
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.refresh,
                                        color: Colors.grey[600],
                                        size: 20,
                                      ),
                                      const SizedBox(width: 4),
                                      const Text('ขอรหัสอีกครั้ง'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            Center(
                              child: Pinput(
                                length: 6,

                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'กรุณากรอกรหัส OTP';
                                  }
                                  if (value.length < 6) {
                                    return 'รหัสไม่ครบ 6 หลัก';
                                  }
                                  return null;
                                },
                                // ตกแต่งเมื่อ Focus หรือ Error
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
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),

                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Obx(
                                  () => Text(
                                    phonenumberController.isLoading.value
                                        ? 'กำลังตรวจสอบ...'
                                        : 'ยืนยัน',
                                    style: TextStyle(
                                      color: Colors.black.withOpacity(0.4),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Obx(
                                  () => ArrowFab(
                                    enabled:
                                        !phonenumberController.isLoading.value,
                                    onPressed:
                                        _onConfirm, // เรียกใช้ฟังก์ชัน Validate
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
