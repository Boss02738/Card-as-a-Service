import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DataCard extends StatelessWidget {
  final Widget child;
  const DataCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(14.r),
          topRight: Radius.circular(14.r),
        ),
      ),
      child: child,
    );
  }
}
