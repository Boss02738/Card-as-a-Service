import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_app/module/controller/type_cards_controller.dart';
import 'package:my_app/views/pages/Create_cards/card_details.dart';
import 'package:my_app/views/widgets/arrow_fab.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RequestPhysical extends StatefulWidget {
  const RequestPhysical({super.key});
  @override
  State<RequestPhysical> createState() => _RequestPhysicaState();
}

class _RequestPhysicaState extends State<RequestPhysical> {
  // รับข้อมูลจาก arguments
  final dynamic args = Get.arguments;
  final ValueNotifier<bool> isButtonEnabled = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final dynamic card = args['card']; // ข้อมูลบัตรปัจจุบันจากหน้า MyCardDetail

    // ดึง Controller มาใช้งาน (ใช้ find เพราะควรถูกสร้างมาจากหน้า List ประเภทบัตรแล้ว)
    final TypeCardsController typeController = Get.put(TypeCardsController());
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF264FAD),
        title: const Text(
          'รายละเอียดบัตรแข็ง',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      //  ใช้ Obx ครอบคลุมเนื้อหาทั้งหมดที่ต้องใช้ข้อมูลจาก cardList
      body: Obx(() {
        //  ค้นหาข้อมูลภายใน Obx เพื่อให้ UI วาดใหม่เมื่อ cardList เปลี่ยนแปลง
        final dynamic cardTypeDetail = typeController.cardList.firstWhere(
          (t) => t['type_debit_id'] == card['type_debit_id'],
          orElse: () => null,
        );

        // แสดง Loading หากข้อมูลยังโหลดไม่เสร็จ
        if (typeController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ส่วน Header รายละเอียดบัตร
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.grey[200],
                child: Text(
                  'รายละเอียดบัตร',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ),

              // ส่วนแสดงภาพบัตร (ใช้ imageBytes ที่ Decode มาจริง)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: 30.h,
                  horizontal: 40.w,
                ),
                color: Colors.grey[50],
                child: Column(
                  children: [
                    if (cardTypeDetail?['type_debit_image'] != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(cardTypeDetail['type_debit_image'], fit: BoxFit.contain),
                      )
                    else
                       Icon(
                        Icons.credit_card,
                        size: 150.r,
                        color: Colors.grey,
                      ),
                     SizedBox(height: 15.h),
                    Text(
                      cardTypeDetail?['type_debit_name'] ?? 'บัตรเดบิต NovaPay',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.all(20.0.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                      'ค่าธรรมเนียม',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                     SizedBox(height: 10.h),
                    //  แสดงค่าธรรมเนียมที่ดึงมาจาก cardTypeDetail
                    _buildFeeRow(
                      'ค่าธรรมเนียมออกบัตรใหม่',
                      '${cardTypeDetail?['entrance_fee'] ?? '0.00'} บาท',
                    ),
                    _buildFeeRow(
                      'ค่าธรรมเนียมรายปี',
                      '${cardTypeDetail?['annual_fee'] ?? '0.00'} บาท',
                    ),

                     Divider(height: 40.h),
                     Text(
                      'รายละเอียด',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                     SizedBox(height: 10.h),
                    // ✅ แสดงรายละเอียดจริงจาก API
                    Text(
                      cardTypeDetail?['type_debit_description'] ?? '-',
                      style:  TextStyle(
                        color: Colors.black87,
                        height: 1.5.h,
                      ),
                    ),
                     SizedBox(height: 30.h),
                    TermsCheckbox(
                      onChanged: (val) => isButtonEnabled.value = val,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ฟังก์ชันช่วยสร้างแถวค่าธรรมเนียมให้สวยงาม
  Widget _buildFeeRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
                GestureDetector(
              onTap: () => Get.back(),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.h),
                    decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                   SizedBox(width: 10.h),
                   Text('ยกเลิก', style: TextStyle(color: Colors.grey, fontSize: 18.sp)),
                ],
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: isButtonEnabled,
              builder: (context, enabled, child) {
                return Row(
                  children: [
                    Text(
                      'ยืนยัน',
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: enabled
                            ? const Color.fromARGB(255, 0, 0, 0)
                            : Colors.grey[400],
                      ),
                    ),
                    SizedBox(width: 12.h),
                    ArrowFab(
                      enabled: enabled,
                      onPressed: () {
                        // ไปหน้ากรอกที่อยู่จัดส่ง
                        Get.toNamed('/address_input', arguments: args);
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
