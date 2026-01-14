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
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF264FAD),
        centerTitle: true,
        leading: Icon(Icons.arrow_back_ios, color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ที่อยู่'),
              TextFormField(
                controller: addressController.addressCtrl,
                decoration: InputDecoration(hintText: 'ที่อยู่ปัจจุบัน'),
              ),
              SizedBox(height: 10),
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
                      decoration: const InputDecoration(hintText: 'จังหวัด'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text('รหัสไปรษณีย์'),
              TextFormField(
                controller: addressController.zipcodeCtrl,
                decoration: InputDecoration(hintText: 'รหัสไปรษณีย์'),
                keyboardType: TextInputType.number,
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('ต่อไป', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 10),

                  ArrowFab(
                    onPressed: () {
                      // ตรวจสอบว่ากรอกข้อมูลครบหรือไม่ (Optional)
                      if (addressController.addressCtrl.text.isNotEmpty) {
                        Get.toNamed(
                          '/pin_verify_page',
                          arguments: {
                            'action': 'request_physical', // ✅ ระบุ Action
                            'card': Get
                                .arguments['card'], // ✅ บัตรที่เลือกมาจากหน้าก่อน
                            'ownerName': Get.arguments['ownerName'],
                            'addressData': addressController
                                .toJson(), // ✅ ข้อมูลที่อยู่
                          },
                        );
                      } else {
                        Get.snackbar(
                          'คำเตือน',
                          'กรุณากรอกข้อมูลที่อยู่ให้ครบถ้วน',
                        );
                      }
                    },
                    enabled: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
