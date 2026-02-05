import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/module/controller/address_controller.dart';
import 'package:my_app/views/widgets/arrow_fab.dart';

class Address extends StatelessWidget {
  const Address({super.key});

  @override
  Widget build(BuildContext context) {
    final AddressController addressController = Get.put(AddressController());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ขอบัตร Physical',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF264FAD),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // 🔹 ส่วนที่ scroll ได้
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ที่อยู่'),
                  TextFormField(
                    controller: addressController.addressCtrl,
                    decoration: const InputDecoration(
                      hintText: 'ที่อยู่ปัจจุบัน',
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: addressController.subdistrictCtrl,
                          decoration: const InputDecoration(hintText: 'ตำบล'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: addressController.districtCtrl,
                          decoration: const InputDecoration(hintText: 'อำเภอ'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: addressController.provincetCtrl,
                          decoration: const InputDecoration(
                            hintText: 'จังหวัด',
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Text('รหัสไปรษณีย์'),
                  TextFormField(
                    controller: addressController.zipcodeCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'รหัสไปรษณีย์'),
                  ),

                  const SizedBox(height: 80), // กันโดนปุ่ม
                ],
              ),
            ),
          ),

          // 🔹 ปุ่มล่าง (fixed)
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text('ต่อไป', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  ArrowFab(
                    enabled: true,
                    onPressed: () async {
                      Get.focusScope?.unfocus();

                      await Future.delayed(const Duration(milliseconds: 120));

                      if (addressController.addressCtrl.text.isNotEmpty) {
                        Get.toNamed(
                          '/pin_verify_page',
                          arguments: {
                            'action': 'request_physical',
                            'card': Get.arguments['card'],
                            'ownerName': Get.arguments['ownerName'],
                            'addressData': addressController.toJson(),
                          },
                        );
                      } else {
                        Get.snackbar(
                          'คำเตือน',
                          'กรุณากรอกข้อมูลที่อยู่ให้ครบถ้วน',
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
