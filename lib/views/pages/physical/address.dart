import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_app/module/controller/address_controller.dart';
import 'package:my_app/views/widgets/arrow_fab.dart';

class Address extends StatefulWidget {
  const Address({super.key});

  @override
  State<Address> createState() => _AddressState();
}

class _AddressState extends State<Address> {
  final AddressController addressController = Get.put(AddressController());

  // ✅ สร้างตัวแปรเช็คสถานะความครบถ้วนของฟอร์ม
  final ValueNotifier<bool> isFormValid = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    // ✅ เพิ่ม Listener ให้กับทุก Controller เพื่อตรวจสอบค่าทุกครั้งที่มีการพิมพ์
    addressController.addressCtrl.addListener(_validateForm);
    addressController.subdistrictCtrl.addListener(_validateForm);
    addressController.districtCtrl.addListener(_validateForm);
    addressController.provincetCtrl.addListener(_validateForm);
    addressController.zipcodeCtrl.addListener(_validateForm);
  }

  // ✅ ฟังก์ชันเช็คว่ากรอกครบทุกช่องหรือไม่
  void _validateForm() {
    bool isValid =
        addressController.addressCtrl.text.isNotEmpty &&
        addressController.subdistrictCtrl.text.isNotEmpty &&
        addressController.districtCtrl.text.isNotEmpty &&
        addressController.provincetCtrl.text.isNotEmpty &&
        addressController.zipcodeCtrl.text.isNotEmpty;

    isFormValid.value = isValid;
  }

  @override
  void dispose() {
    // ล้าง Listener เมื่อเลิกใช้งาน
    addressController.addressCtrl.removeListener(_validateForm);
    addressController.subdistrictCtrl.removeListener(_validateForm);
    addressController.districtCtrl.removeListener(_validateForm);
    addressController.provincetCtrl.removeListener(_validateForm);
    addressController.zipcodeCtrl.removeListener(_validateForm);
    isFormValid.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ขอบัตร Physical',
          style: TextStyle(color: Colors.white, fontSize: 18.sp),
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
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ที่อยู่ปัจจุบัน'),
                  TextFormField(
                    controller: addressController.addressCtrl,
                    decoration: const InputDecoration(
                      hintText: 'บ้านเลขที่, ถนน, ซอย',
                    ),
                  ),
                  SizedBox(height: 15.h),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: addressController.subdistrictCtrl,
                          decoration: const InputDecoration(
                            hintText: 'ตำบล/แขวง',
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: TextFormField(
                          controller: addressController.districtCtrl,
                          decoration: const InputDecoration(
                            hintText: 'อำเภอ/เขต',
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.h),
                  TextFormField(
                    controller: addressController.provincetCtrl,
                    decoration: const InputDecoration(hintText: 'จังหวัด'),
                  ),
                  SizedBox(height: 15.h),
                  const Text('รหัสไปรษณีย์'),
                  TextFormField(
                    controller: addressController.zipcodeCtrl,
                    keyboardType: TextInputType.number,
                    // เพิ่มบรรทัดนี้เพื่อจำกัดจำนวน 5 ตัวอักษร
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(5),
                      FilteringTextInputFormatter
                          .digitsOnly, // แนะนำให้ใส่ตัวนี้ด้วยเพื่อให้พิมพ์ได้เฉพาะตัวเลขเท่านั้น
                    ],
                    decoration: const InputDecoration(
                      hintText: 'รหัสไปรษณีย์',
                      counterText:
                          "", // ใส่บรรทัดนี้ถ้าไม่ต้องการให้มีตัวเลข 0/5 โชว์ที่มุมขวาล่าง
                    ),
                  ),
                  SizedBox(height: 80.h),
                ],
              ),
            ),
          ),

          // 🔹 ปุ่มล่าง (เปลี่ยนสีและสถานะตามการกรอก)
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
              child: ValueListenableBuilder<bool>(
                valueListenable: isFormValid,
                builder: (context, isValid, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'ต่อไป',
                        style: TextStyle(
                          fontSize: 16.sp,
                          // fontWeight: FontWeight.bold,
                          // ✅ สีข้อความจะเปลี่ยนตามสถานะ
                          color: isValid
                              ? const Color.fromARGB(255, 0, 0, 0)
                              : Colors.grey,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      ArrowFab(
                        enabled: isValid, // ✅ ส่งค่า true/false ไปที่ Widget
                        onPressed: isValid
                            ? () async {
                                Get.focusScope?.unfocus();
                                await Future.delayed(
                                  const Duration(milliseconds: 150),
                                );
                                Get.toNamed(
                                  '/pin_verify_page',
                                  arguments: {
                                    'action': 'request_physical',
                                    'card': Get.arguments['card'],
                                    'ownerName': Get.arguments['ownerName'],
                                    'addressData': addressController.toJson(),
                                  },
                                );
                              }
                            : () {}, // ถ้าไม่ Valid จะกดไม่ได้
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
