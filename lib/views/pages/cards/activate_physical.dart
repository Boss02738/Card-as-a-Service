import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/views/widgets/arrow_fab.dart';

class ActivatePhysical extends StatefulWidget {
  const ActivatePhysical({super.key});

  @override
  State<ActivatePhysical> createState() => _ActivatePhysicalState();
}

class _ActivatePhysicalState extends State<ActivatePhysical> {
  final dynamic args = Get.arguments;

  // Controllers สำหรับแต่ละช่อง (เลข 4 หลักสุดท้าย)
  final List<TextEditingController> digitCtrls = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> focusNodes = List.generate(4, (_) => FocusNode());

  final expiryCtrl = TextEditingController();
  final cvvCtrl = TextEditingController();
  final ValueNotifier<bool> isFormValid = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    // ตรวจสอบความถูกต้องทุกครั้งที่กรอก
    for (var ctrl in digitCtrls) {
      ctrl.addListener(_validateForm);
    }
    expiryCtrl.addListener(_validateForm);
    cvvCtrl.addListener(_validateForm);
  }

  void _validateForm() {
    String lastFour = digitCtrls.map((e) => e.text).join();
    isFormValid.value =
        lastFour.length == 4 &&
        expiryCtrl.text.length >= 4 &&
        cvvCtrl.text.length == 3;
  }

  // ไฟล์: activate_physical.dart

void proceedToVerifyPin() {
  String inputLastFour = digitCtrls.map((e) => e.text).join();

  Get.toNamed(
    '/pin_verify_page',
    arguments: {
      'action': 'activate_physical_flow',
      'card': args['card'], // ✅ มั่นใจว่าในนี้มี card_id
      'ownerName': args['ownerName'],
      'input_data': {
        'last_digits': inputLastFour,
        'expiry': expiryCtrl.text,
        'cvv': cvvCtrl.text,
      },
    },
  );
}
  @override
  Widget build(BuildContext context) {
    final dynamic card = args['card'];
    final String ownerName = args['ownerName'];
    final dynamic sensitive = args['sensitive'] ?? {};
    final String fullPan = sensitive['encrypted_pan'] ?? "XXXXXXXXXXXXXXXX";

    // จัดรูปแบบเลขหน้า 12 หลัก: 1234 - 6922 - 3772 -
    String prefix = "XXXX - XXXX - XXXX - ";
    if (fullPan.length >= 12) {
      prefix =
          "${fullPan.substring(0, 4)} - ${fullPan.substring(4, 8)} - ${fullPan.substring(8, 12)} - ";
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'เปิดใช้งานบัตร',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF264FAD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(card, ownerName),
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                children: [
                  const Text(
                    "กรอกเลขบัตรเดบิต",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildFigmaInputRow(prefix),

                  const SizedBox(height: 35),
                  Row(
                    children: [
                      Expanded(
                        child: _buildLabelInput(
                          "วันหมดอายุ",
                          "MM/YY",
                          expiryCtrl,
                          5,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildLabelInput(
                          "cvv/cvc",
                          "ระบุเลข",
                          cvvCtrl,
                          3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // Widget ช่องกรอก 4 หลักแบบสี่เหลี่ยมแยก
  Widget _buildFigmaInputRow(String prefix) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 8,
      ), // ลด padding
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: FittedBox(
        // 👈 เพิ่ม FittedBox เพื่อป้องกันการ Overflow ทุกขนาดหน้าจอ
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              prefix,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
            ...List.generate(
              4,
              (index) => Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 2,
                ), // ลดระยะห่างระหว่างช่อง
                width: 28,
                height: 38, // ลดขนาดช่องสี่เหลี่ยมลงเล็กน้อย
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: TextField(
                  controller: digitCtrls[index],
                  focusNode: focusNodes[index],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    counterText: "",
                    border: InputBorder.none,
                  ),
                  onChanged: (val) {
                    if (val.isNotEmpty && index < 3)
                      focusNodes[index + 1].requestFocus();
                    if (val.isEmpty && index > 0)
                      focusNodes[index - 1].requestFocus();
                  },
                ), 
              ),
            ),   
          ],
        ),
      ),
    );
  }

  Widget _buildLabelInput(
    String label,
    String hint,
    TextEditingController ctrl,
    int max,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          maxLength: max,
          decoration: InputDecoration(
            hintText: hint,
            counterText: "",
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(dynamic card, String ownerName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 35),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3B5BDB), Color(0xFF162E7A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.credit_card, color: Colors.white54, size: 50),
          const SizedBox(height: 15),
          const Text(
            "NovaPay Debit Card",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "ชื่อหน้าบัตร: ${ownerName.toUpperCase()}",
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            "หมายเลข: **** **** **** ${card['last_digits']}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: ValueListenableBuilder<bool>(
          valueListenable: isFormValid,
          builder: (context, isValid, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "ยืนยัน",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isValid ? const Color(0xFF264FAD) : Colors.grey,
                  ),
                ),
                const SizedBox(width: 15),
                ArrowFab(
                  onPressed: isValid ? proceedToVerifyPin : () {},
                  enabled: isValid,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var c in digitCtrls) {
      c.dispose();
    }
    for (var f in focusNodes) {
      f.dispose();
    }
    expiryCtrl.dispose();
    cvvCtrl.dispose();
    super.dispose();
  }
}
