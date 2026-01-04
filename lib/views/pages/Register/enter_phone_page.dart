import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/module/controller/header_text_controller.dart';
import 'package:my_app/module/controller/phonenumber_controller.dart';
import 'package:my_app/views/pages/Register/confirm_otp.dart';
import 'package:my_app/views/widgets/data_card.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/header_texts.dart';
import '../../widgets/arrow_fab.dart';

class EnterPhonePage extends StatefulWidget {
  const EnterPhonePage({super.key});

  @override
  State<EnterPhonePage> createState() => _EnterPhonePageState();
}



class _EnterPhonePageState extends State<EnterPhonePage> {
  final PhonenumberController phonenumberController = Get.put(
  PhonenumberController()
);
final HeaderTextController headerTextController = Get.put(
  HeaderTextController(),
);
  final _phoneCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      phonenumberController.reset();
      _phoneCtrl.clear();

      headerTextController.setHeaderText(
        'เข้าใช้งาน NovaPay',
        'กรุณากรอกข้อมูล\nเบอร์มือถือ',
      );
    });
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    phonenumberController.setPhoneNumber(_phoneCtrl.text);

    if (phonenumberController.isLoading.value) return;

    bool success = await phonenumberController.submitPhone();

    if (success) {
      Get.to(() => const Confirm_otp())?.then((value) {
        // ล้างค่าเมื่อย้อนกลับมาถึงหน้าเดิม
        _phoneCtrl.clear();
        // phonenumberController.reset();
        headerTextController.setHeaderText(
          'เข้าใช้งาน NovaPay',
          'กรุณากรอกข้อมูล\nเบอร์มือถือ',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const GradientHeader(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                const BrandLogo(),
                const SizedBox(height: 30),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 22),
                  child: HeaderTexts(),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: DataCard(
                    child: Form(
                    key: _formKey  ,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          const Text(
                            'กรอกเบอร์มือถือที่ต้องการใช้งาน NovaPay',
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              hintText: 'ระบุเบอร์มือถือ',
                            ),
                            validator: (v) {
                              final s = (v ?? '').trim();
                              if (s.length != 10) return 'เบอร์ไม่ถูกต้อง';
                              return null;
                            },
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Obx(
                                () => Text(
                                  phonenumberController.isLoading.value
                                      ? 'กำลังส่ง...'
                                      : 'ยืนยัน',
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // เปลี่ยน enabled มาอิงตาม phonenumberController.isLoading
                              Obx(
                                () => ArrowFab(
                                  enabled:
                                      !phonenumberController.isLoading.value,
                                  onPressed: _submit,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
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
