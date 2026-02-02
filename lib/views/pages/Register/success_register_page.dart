import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/module/controller/mainTab_Controller%20.dart';
import 'package:my_app/views/widgets/gradient_header.dart';

class SuccessRegisterPage extends StatelessWidget {
  const SuccessRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GradientHeader(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 340,
                  height: 400,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // ชิดซ้ายทุกตัว
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Image.asset(
                              "assets/images/novapay_logo.png",
                              width: 120,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        'ยินดีต้อนรับ\nเข้าสู่บริการ NovaPay',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'ธนาคารทำการสมัครและเปิดบริการ\nNovaPay เรียบร้อยแล้ว',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(179, 255, 255, 255),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 100), // ระยะห่างระหว่างกล่องกับปุ่ม
                // 3. ปุ่มกดด้านล่าง
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      // success_register_page.dart
                      onPressed: () {
                        try {
                          // พยายามหา ถ้าเจอให้เปลี่ยน Tab
                          Get.find<MainTabController>().changeTab(0);
                          Get.offAllNamed(
                            '/main_tab_page',
                          ); // ชื่อ Route ของหน้าที่รวม Tab ไว้
                        } catch (e) {
                          // 🛡️ ถ้าไม่เจอ (Error ที่คุณเจออยู่) ให้สร้างใหม่แล้วค่อยย้ายหน้า
                          Get.put(MainTabController());
                          Get.offAllNamed('/main_tab_page');
                        }
                      },
                      // onPressed: () {
                      //   Get.offAllNamed('/login-pin');
                      // },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF17337B),
                        minimumSize: const Size(280, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'เข้าสู่ระบบ',
                        style: TextStyle(color: Colors.white, fontSize: 16),
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
