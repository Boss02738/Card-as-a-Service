import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_app/module/controller/phonenumber_controller.dart';
import 'package:my_app/views/widgets/brand_logo.dart';
import 'package:my_app/views/widgets/data_card.dart';
import 'package:my_app/views/widgets/gradient_header.dart';
import 'package:my_app/views/widgets/arrow_fab.dart';

class ChangeDevicePage extends StatefulWidget {
  const ChangeDevicePage({super.key});

  @override
  State<ChangeDevicePage> createState() => _ChangeDevicePageState();
}

class _ChangeDevicePageState extends State<ChangeDevicePage> {
  final _idCardCtrl = TextEditingController();
  final _accNoCtrl = TextEditingController();
  final phoneCtrl = Get.find<PhonenumberController>();

  final ValueNotifier<bool> canNext = ValueNotifier(false);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const GradientHeader(),
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 40.h),
                const BrandLogo(),
                SizedBox(height: 40.h),
                Text(
                  'เข้าใช้งานบัญชีเดิม',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20.h),
                Expanded(
                  child: DataCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20.h),
                        Text(
                          'เลขบัตรประชาชน',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                        ),

                        // isPhoneComplete.value = value.trim().length == 10;
                        TextField(
                          controller: _idCardCtrl,
                          keyboardType: TextInputType.number,
                          maxLength: 13,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            hintText: 'กรอกเลขบัตรประชาชน',
                            counterText: '',
                          ),
                          onChanged: (_) {
                            canNext.value =
                                _idCardCtrl.text.length == 13 &&
                                _accNoCtrl.text.length == 10;
                          },
                        ),
                        SizedBox(height: 30.h),
                        Text(
                          'เลขที่บัญชี',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                        ),
                        TextField(
                          controller: _accNoCtrl,
                          keyboardType: TextInputType.number,
                          maxLength: 10,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            hintText: 'กรอกเลขบัญชี',
                            counterText: '',
                          ),
                          onChanged: (_) {
                            canNext.value =
                                _idCardCtrl.text.length == 13 &&
                                _accNoCtrl.text.length == 10;
                          },
                        ),

                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text('ต่อไป'),
                            SizedBox(width: 10.w),
                            // ใน ChangeDevicePage
                            ValueListenableBuilder<bool>(
                              valueListenable: canNext,
                              builder: (context, enable, _) {
                                return ArrowFab(
                                  enabled: enable,
                                  onPressed: enable
                                      ? () {
                                          final String verifiedMobile =
                                              Get.arguments?['mobileNumber'] ??
                                              phoneCtrl.phoneNumber.value;

                                          Get.toNamed(
                                            '/face_verify',
                                            arguments: {
                                              'action': 'change_device_flow',
                                              'citizenId': _idCardCtrl.text,
                                              'accountNumber': _accNoCtrl.text,
                                              'mobileNumber': verifiedMobile,
                                            },
                                          );
                                        }
                                      : () {}, // กันกด
                                );
                              },
                            ),

                            SizedBox(height: 30.h),
                          ],
                        ),
                        SizedBox(height: 16.h),
                      ],
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
}
