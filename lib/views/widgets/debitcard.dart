// debitcard.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert'; // สำหรับ utf8 และ base64
import 'dart:typed_data'; // สำหรับ Uint8List

class BankCard extends StatelessWidget {
  final dynamic card;
  final String ownerName;
  final String? cardName;

  const BankCard({
    super.key,
    required this.card,
    required this.ownerName,
    this.cardName,
  });

// ... ส่วนของโค้ดก่อนหน้า ...

  @override
  Widget build(BuildContext context) {
    // 1. ดึง String base64 ออกมา และเช็คว่าชื่อคีย์ใน API ตรงกัน (ในรูปคือ 'type_debit_image')
    final String? base64String = card['card_image'];
    Uint8List? imageBytes;

    // 2. แปลงจาก String เป็น Uint8List
    if (base64String != null && base64String.isNotEmpty) {
      try {
        imageBytes = base64Decode(base64String);
      } catch (e) {
        debugPrint("Error decoding base64: $e");
      }
    }

    return AspectRatio(
      aspectRatio: 1.58,
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.r),
          // 3. เปลี่ยนการโหลดรูปภาพจาก Network เป็น Memory
          image: imageBytes != null
              ? DecorationImage(
                  image: MemoryImage(imageBytes), // ใช้ MemoryImage สำหรับ Base64
                  fit: BoxFit.cover,
                )
              : null,
          gradient: imageBytes == null
              ? const LinearGradient(
                  colors: [Color(0xFF3B5BDB), Color(0xFF162E7A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
// ... ส่วนของโค้ดที่เหลือ ...
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.r,
              offset: Offset(0, 5.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              cardName?.toUpperCase() ?? '',
              style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text(
              ownerName.toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              "**** **** **** ${card['last_digits'] ?? '****'}",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                letterSpacing: 2.w,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  card['virtual'] == true ? "Virtual Card" : "Physical Card",
                  style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                ),
            
              ],
            ),
          ],
        ),
      ),
    );
  }
}