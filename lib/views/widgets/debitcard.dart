import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BankCard extends StatelessWidget {
  final dynamic card;
  final String ownerName;
  final String cardName;

  const BankCard({
    super.key,
    required this.card,
    required this.ownerName,
    required this.cardName,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.58, // 🔒 ล็อกสเกลเดียวกับ MyCardDetail
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.r),
          image: card['card_image'] != null
              ? DecorationImage(
                  image: MemoryImage(base64Decode(card['card_image'])),
                  fit: BoxFit.cover,
                )
              : null,
          gradient: card['card_image'] == null
              ? const LinearGradient(
                  colors: [Color(0xFF3B5BDB), Color(0xFF162E7A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
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
              cardName.toUpperCase(),
              style: TextStyle(color: Colors.white, fontSize: 16.sp),
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
              "**** **** **** ${card['last_digits']}",
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
                Image.network(
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Mastercard-logo.svg/1280px-Mastercard-logo.svg.png',
                  width: 35.w,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
