import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/views/widgets/brand_logo.dart';
import 'package:my_app/views/widgets/data_card.dart';
import 'package:my_app/views/widgets/gradient_header.dart';

class UserSelectionPage extends StatelessWidget {
  const UserSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const GradientHeader(),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 50),
                const BrandLogo(),
                const SizedBox(height: 50),
                Expanded(
                  child: DataCard(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _selectionTile(
                          title: 'เปิดใช้งานบัญชีใหม่ NovaPay',
                          subtitle: 'เบอร์ใหม่ ไม่เคยมีบัญชี หรือต้องการสมัครใหม่',
                          icon: Icons.person_add_alt_1,
                          onTap: () => Get.toNamed('/idcard_verify'), // Flow สมัครใหม่เดิม
                        ),
                        const SizedBox(height: 24),
                        _selectionTile(
                          title: 'เข้าสู่ระบบบัญชีเดิม',
                          subtitle: 'มีบัญชีอยู่แล้ว ต้องการย้ายเครื่องหรือติดตั้งแอปใหม่',
                          icon: Icons.app_registration_rounded,
                          onTap: () => Get.toNamed('/change_device'), // ไป Flow เปลี่ยนเครื่อง
                        ),
                      ],
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

  Widget _selectionTile({required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade100),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: const Color(0xFF17337B)),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}