import 'package:date_format_field/date_format_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/module/controller/info_controller.dart';
import 'package:my_app/views/pages/face_verify.dart';
import 'package:my_app/views/widgets/arrow_fab.dart';
import 'package:my_app/views/widgets/brand_logo.dart';
import 'package:my_app/views/widgets/data_card.dart';
import 'package:my_app/views/widgets/gradient_header.dart';
import 'package:my_app/views/widgets/header_texts.dart';

import '../../module/controller/header_text_controller.dart';

class Info extends StatefulWidget {
  const Info({super.key});

  @override
  State<Info> createState() => _InfoState();
}

class _InfoState extends State<Info> {
  final HeaderTextController headerTextController =
      Get.find<HeaderTextController>();

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
                              decoration: InputDecoration(
                                // border: OutlineInputBorder(),
                                hintText: 'กรอกหมายเลขบัตรประชาชน',
                              ),
                              keyboardType: TextInputType.number,
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
                              onComplete: (date) {
                                if (date != null) {
                                  infoController.birthdayDateCtrl.text = "${date.day}/${date.month}/${date.year}";
                                }
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
                            ),
                            TextFormField(
                              controller: infoController.lastNameThCtrl,
                              decoration: InputDecoration(
                                // border: OutlineInputBorder(),
                                hintText: 'นามสกุล',
                              ),
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
                            ),
                            TextFormField(
                              controller: infoController.lastNameEnCtrl,
                              decoration: InputDecoration(
                                // border: OutlineInputBorder(),
                                hintText: 'นามสกุล',
                              ),
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
                                    Get.to(() => const FaceVerify());
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
