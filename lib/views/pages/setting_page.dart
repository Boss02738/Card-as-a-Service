import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('ตั้งค่า', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF264FAD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 5.0),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('ข้อมูลส่วนตัว'),
              subtitle: const Text(
                'ชื่อผู้ใช้,อีเมล,เบอร์โทรศัพท์',
                style: TextStyle(fontSize: 12,color:Color.fromARGB(255, 104, 104, 104)),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color.fromARGB(255, 169, 169, 169),
              ),

              onTap: () {
                Get.toNamed('/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.credit_card,color: Color.fromARGB(255, 134, 133, 133),),
              
              title: const Text('จัดการบัตรเดบิต'),
              subtitle: const Text(
                'ปรับวงเงิน,เปิเปิด/ปิดใช้งานบัตร,ดูเลขบัตรม,ขอบัตรจริง',
                style: TextStyle(fontSize: 12,color:Color.fromARGB(255, 104, 104, 104)),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color.fromARGB(255, 169, 169, 169),
              ),

              onTap: () {
                Get.toNamed('/my_cards');
              },
            ),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('ความปลอดภัย'),
              subtitle: const Text(
                'เปลี่ยนรหัส PIN',
                style: TextStyle(fontSize: 12,color:Color.fromARGB(255, 104, 104, 104)),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color.fromARGB(255, 169, 169, 169),
              ),

              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
