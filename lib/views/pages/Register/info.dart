import 'package:date_format_field/date_format_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:my_app/module/controller/info_controller.dart';
import 'package:my_app/views/pages/Register/face_verify.dart';
import 'package:my_app/views/widgets/arrow_fab.dart';
import 'package:my_app/views/widgets/brand_logo.dart';
import 'package:my_app/views/widgets/data_card.dart';
import 'package:my_app/views/widgets/gradient_header.dart';
import 'package:my_app/views/widgets/header_texts.dart';

import '../../../module/controller/header_text_controller.dart';

class Info extends StatefulWidget {
  const Info({super.key});

  @override
  State<Info> createState() => _InfoState();
}

class _InfoState extends State<Info> {
  final HeaderTextController headerTextController =
      Get.find<HeaderTextController>();
  final _formKey = GlobalKey<FormState>();
  bool _isAgeValid(DateTime birthDate) {
    final today = DateTime.now();

    int age = today.year - birthDate.year;

    // ถ้ายังไม่ถึงวันเกิดปีนี้ ให้ลบอายุออก 1
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }

    return age >= 12;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      headerTextController.setHeaderText(
        'ข้อมูลส่วนตัว',
        'ตรวจสอบและแก้ไขข้อมูลส่วนตัว',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final InfoController infoController = Get.put(InfoController());

    return Scaffold(
      body: Stack(
        children: [
          GradientHeader(),
          SafeArea(
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
                SizedBox(height: 20),
                Expanded(
                  child: DataCard(
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 16),
                            Text(
                              'บัตรประชาชน',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextFormField(
                              controller: infoController.idCardCtrl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(13),
                                FilteringTextInputFormatter
                                    .digitsOnly, // แนะนำให้ใส่ตัวนี้ด้วยเพื่อให้พิมพ์ได้เฉพาะตัวเลขเท่านั้น
                              ],
                              decoration: const InputDecoration(
                                hintText: 'กรอกหมายเลขบัตรประชาชน',
                                counterText: "",
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'กรุณากรอกหมายเลขบัตรประชาชน';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),
                            Text(
                              'วัน/เดือน/ปีเกิด',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            DateFormatField(
                              type: DateFormatType.type2,
                              focusNode: AlwaysDisabledFocusNode(),
                              lastDate: DateTime.now(), // ❌ เลือกอนาคตไม่ได้
                              onComplete: (date) {
                                if (date == null) return;

                                final now = DateTime.now();
                                final age =
                                    now.year -
                                    date.year -
                                    ((now.month < date.month ||
                                            (now.month == date.month &&
                                                now.day < date.day))
                                        ? 1
                                        : 0);

                                if (age < 12) {
                                  Get.snackbar(
                                    'ไม่ผ่านเงื่อนไข',
                                    'ต้องมีอายุอย่างน้อย 12 ปี',
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                  infoController.birthdayDateCtrl.clear();
                                  return;
                                }

                                infoController.birthdayDateCtrl.text =
                                    "${date.day.toString().padLeft(2, '0')}-"
                                    "${date.month.toString().padLeft(2, '0')}-"
                                    "${date.year}";
                              },
                            ),

                            SizedBox(height: 20),
                            Text(
                              'ชื่อ-นามสกุล (ภาษาไทย)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextFormField(
                              controller: infoController.firstNameThCtrl,
                              decoration: InputDecoration(
                                // border: OutlineInputBorder(),
                                hintText: 'ชื่อ',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'กรุณากรอกชื่อภาษาไทย';
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              controller: infoController.lastNameThCtrl,
                              decoration: InputDecoration(
                                // border: OutlineInputBorder(),
                                hintText: 'นามสกุล',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'กรุณากรอกนามสกุลภาษาไทย';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),
                            Text(
                              'ชื่อ-นามสกุล (ภาษาอังกฤษ)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextFormField(
                              controller: infoController.firstNameEnCtrl,
                              decoration: InputDecoration(
                                // border: OutlineInputBorder(),
                                hintText: 'ชื่อ',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'กรุณากรอกชื่อภาษาอังกฤษ';
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              controller: infoController.lastNameEnCtrl,
                              decoration: InputDecoration(
                                // border: OutlineInputBorder(),
                                hintText: 'นามสกุล',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'กรุณากรอกนามสกุลภาษาอังกฤษ';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),
                            Text(
                              'อีเมล',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextFormField(
                              controller: infoController.emailCtrl,
                              decoration: InputDecoration(
                                // border: OutlineInputBorder(),
                                hintText: 'อีเมล',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'กรุณากรอกอีเมล';
                                }
                                if (!GetUtils.isEmail(value)) {
                                  // 👈 ใช้ตัวนี้ของ GetX ได้เลยครับ ง่ายมาก!
                                  return 'รูปแบบอีเมลไม่ถูกต้อง';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('ต่อไป'),
                                SizedBox(width: 10),
                                ArrowFab(
                                  enabled: true,
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      if (infoController
                                          .birthdayDateCtrl
                                          .text
                                          .isEmpty) {
                                        Get.snackbar(
                                          'ข้อมูลไม่ครบ',
                                          'กรุณาเลือกวันเกิด',
                                          snackPosition: SnackPosition.BOTTOM,
                                        );
                                        return;
                                      }

                                      Get.to(
                                        () => const FaceVerify(),
                                        arguments: Get.arguments,
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
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
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
