import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ButtonBottom extends StatelessWidget {
  const ButtonBottom({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Padding(
              padding:  EdgeInsets.all(8.0.r),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  // gradient: LinearGradient(
                  //   colors: [Colors.red, Colors.blue],
                  // ),
                ),
                onPressed: () {},
                child: Text('ปุ่มตัวอย่าง',style: TextStyle(color: Colors.white),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
