import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_app/module/controller/home_controller.dart';

class SensitiveDataPage extends StatelessWidget {
  const SensitiveDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dynamic args = Get.arguments;
    final dynamic card = args['card'];
    final dynamic sensitive = args['sensitive'];
    final String ownerName = args['ownerName'];
    final String cardName = card['card_name'] ?? "NovaPay";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('รายละเอียดบัตร', style: TextStyle(color: Colors.white, fontSize: 18.sp)),
        centerTitle: true,
        backgroundColor: const Color(0xFF264FAD),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20.r),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ✅ ส่วนรูปบัตร: ปรับ Scale ให้เท่ากับ MyCardDetail ทุกประการ
            Container(
              padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
              child: _buildSensitiveCard(card, sensitive, ownerName, cardName),
            ),
            
            Padding(
              padding: EdgeInsets.only(left: 20.w, bottom: 10.h),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "รายละเอียดบัตร",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                ),
              ),
            ),

            // ส่วนตารางข้อมูลด้านล่าง
            _buildDetailSection([
              _buildRow("ชื่อ นามสกุล", ownerName),
              _buildRow(
                "สถานะบัตร", 
                card['status'] == 'active' ? "เปิดใช้งาน" : "ปิดใช้งาน", 
                valueColor: card['status'] == 'active' ? Colors.green : Colors.red
              ),
              _buildRow("ผูกกับบัญชี", Get.find<HomeController>().accountNumber.value),
              _buildRow("วันหมดอายุ (EXP)", sensitive['expiry']),
              _buildRow("CVV / CVC", sensitive['cvv']),
            ]),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  //  ฟังก์ชันวาดบัตรที่ใช้ Scale เดียวกับ MyCardDetail แต่โชว์เลขครบฝ
  Widget _buildSensitiveCard(dynamic card, dynamic sensitive, String name, String cardname) {
    return AspectRatio(
      aspectRatio: 1.58, // สัดส่วนมาตรฐานเดียวกับ MyCardDetail
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.r),
          image: card['card_image'] != null
              ? DecorationImage( 
                image:NetworkImage(card['card_image']),
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
            BoxShadow(color: Colors.black26, blurRadius: 10.r, offset: Offset(0, 5.h)),
          ],
        ),
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(cardname.toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 16.sp)),
            
            const Spacer(), //  เว้นช่องไฟเหมือนใน MyCard

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.toUpperCase(), 
                  style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w500)
                ),
                SizedBox(height: 5.h),
                Text(
                  _formatFullPan(sensitive['pan']),
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 18.sp, 
                    letterSpacing: 1.2.w, // ลดลงนิดหน่อยเพื่อให้ 16 ตัวไม่ล้น
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),

            SizedBox(height: 10.h), 

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text("EXP: ${sensitive['expiry']}", style: TextStyle(color: Colors.white70, fontSize: 13.sp)),
                    SizedBox(width: 15.w),
                    Text("CVV: ${sensitive['cvv']}", style: TextStyle(color: Colors.white70, fontSize: 13.sp)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatFullPan(String? pan) {
    if (pan == null || pan.length < 16) return pan ?? "";
    return "${pan.substring(0, 4)}  ${pan.substring(4, 8)}  ${pan.substring(8, 12)}  ${pan.substring(12, 16)}";
  }

  Widget _buildDetailSection(List<Widget> children) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5.r, offset: Offset(0, 2.h)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildRow(String label, String value, {Color? valueColor}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: const Color(0xFF595858), fontSize: 13.sp)),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}