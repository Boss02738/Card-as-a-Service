import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_app/module/controller/mainTab_Controller%20.dart';
import 'package:my_app/views/widgets/brand_logo.dart';
import 'package:my_app/views/widgets/buildHeader.dart';
import 'package:my_app/views/widgets/exit_confirmation_dialog.dart';
import 'package:my_app/views/widgets/gradient_header.dart';

class SettingTabPage extends StatelessWidget {
  const SettingTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BackButtonInterceptor(
      child: Scaffold(
        body: Stack(
          children: [
            const GradientHeader(),
            ListView(
              children: [
                SizedBox(height: 10.h),
                const Buildheader(),
                SizedBox(height: 20.h),
                ListTile(
                  leading: const Icon(
                    Icons.person,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                  title: const Text(
                    'ข้อมูลส่วนตัว',
                    style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                  ),
                  subtitle: const Text(
                    'ชื่อผู้ใช้,อีเมล,เบอร์โทรศัพท์',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
      
                  onTap: () {
                    Get.toNamed('/profile');
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.credit_card,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
      
                  title:  Text(
                    'จัดการบัตรเดบิต',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                  subtitle: Text(
                    'ปรับวงเงิน,เปิด/ปิดใช้งานบัตร,ดูเลขบัตร,ขอบัตรจริง',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
      
                  onTap: () {
                    Get.find<MainTabController>().changeTab(2);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.security,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
      
                  title: const Text(
                    'ความปลอดภัย',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                  subtitle: const Text(
                    'เปลี่ยนรหัส PIN',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
      
                  onTap: () {
                    Get.toNamed("/change_pin");
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SettingDetailPage extends StatelessWidget {
  const SettingDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ตั้งค่า'), leading: BackButton()),
      // body: ...
    );
  }
}
