import 'package:flutter/material.dart';
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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('รายละเอียดบัตร', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF264FAD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // ส่วนแสดงบัตรแบบโชว์ข้อมูลครบ
          Container(
            padding: const EdgeInsets.all(20),
            child: _buildFullInfoCard(card, sensitive, ownerName),
          ),
          
          const SizedBox(height: 20),
          const Text("รายละเอียดบัตร", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          // ส่วนตารางข้อมูลด้านล่าง
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildRow("ชื่อ นามสกุล", ownerName),
                _buildRow("สถานะบัตร", card['status'] == 'active' ? "เปิดใช้งาน" : "ปิดใช้งาน", 
                    valueColor: card['status'] == 'active' ? Colors.green : Colors.red),
                _buildRow("ผูกกับบัญชี", Get.find<HomeController>().accountNumber.value),
                _buildRow("EXP : ${sensitive['expiry']}", "CVV/CVC : ${sensitive['cvv']}"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullInfoCard(dynamic card, dynamic sensitive, String name) {
    return Container(
      height: 200,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(colors: [Color(0xFF3B5BDB), Color(0xFF162E7A)]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("NovaPay", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          Text(name.toUpperCase(), style: const TextStyle(color: Colors.white)),
          // ✅ แสดงเลขบัตรเต็มจาก API
          Text(
            _formatFullPan(sensitive['pan']),
            style: const TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 2),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("EXP : ${sensitive['expiry']}", style: const TextStyle(color: Colors.white)),
              Text("CVC/CVV : ${sensitive['cvv']}", style: const TextStyle(color: Colors.white)),
              Image.network('https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Mastercard-logo.svg/1280px-Mastercard-logo.svg.png', width: 40),
            ],
          ),
        ],
      ),
    );
  }

  String _formatFullPan(String pan) {
    if (pan.length < 16) return pan;
    return "${pan.substring(0, 4)}  ${pan.substring(4, 8)}  ${pan.substring(8, 12)}  ${pan.substring(12, 16)}";
  }

  Widget _buildRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color.fromARGB(255, 78, 78, 78), fontSize: 14)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: valueColor ?? Colors.black)),
        ],
      ),
    );
  }
}