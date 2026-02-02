import 'package:flutter/material.dart';
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
                        TextField(
                          controller: _idCardCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'กรอกหมายเลข 13 หลัก',
                          ),
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
                          decoration: const InputDecoration(
                            hintText: 'กรอกเลขบัญชีเงินฝาก',
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text('ต่อไป'),
                            SizedBox(width: 10.w),
                            // ใน ChangeDevicePage
                            ArrowFab(
                              enabled: true,
                              onPressed: () {
                                if (_idCardCtrl.text.length == 13 &&
                                    _accNoCtrl.text.isNotEmpty) {
                                  Get.toNamed(
                                    '/face_verify',
                                    arguments: {
                                      'action': 'change_device_flow',
                                      'citizenId': _idCardCtrl.text,
                                      'accountNumber': _accNoCtrl.text,
                                      'mobileNumber':
                                          phoneCtrl.phoneNumber.value,
                                      // อย่าลืมส่งเบอร์โทรไปด้วยถ้ายังไม่มีใน Storage
                                    },
                                  );
                                } else {
                                  Get.snackbar(
                                    'แจ้งเตือน',
                                    'กรุณากรอกข้อมูลให้ครบถ้วน',
                                  );
                                }
                              },
                            ),
                            SizedBox(height: 30.h),
                          ],
                        ),
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
