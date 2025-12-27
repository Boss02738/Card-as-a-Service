import 'package:get/get.dart';
import 'package:my_app/module/controller/info_controller.dart';
import 'package:my_app/module/controller/phonenumber_controller.dart';

class PinController extends GetxController {
  var enteredPin = ''.obs; // PIN ที่กำลังพิมพ์
  var firstPin = ''.obs; // เก็บ PIN รอบแรก
  var isConfirmMode = false.obs; // สลับโหมด ตั้งค่า/ยืนยัน
  var isLoading = false.obs;

//pin
  void addNumber(int number) {
    if (enteredPin.value.length < 6) {
      enteredPin.value += number.toString();
    }

    // เมื่อครบ 6 หลัก
    if (enteredPin.value.length == 6) {
      Future.delayed(const Duration(milliseconds: 200), () {
        handlePinComplete();
      });
    }
  }

  void deleteNumber() {
    if (enteredPin.value.isNotEmpty) {
      enteredPin.value = enteredPin.value.substring(
        0,
        enteredPin.value.length - 1,
      );
    }
  }

  void handlePinComplete() {
    if (!isConfirmMode.value) {
      // รอบแรกสำเร็จ
      firstPin.value = enteredPin.value;
      enteredPin.value = '';
      isConfirmMode.value = true;
    } else {
      // ตรวจรอบสอง
      if (enteredPin.value == firstPin.value) {
        Get.snackbar('สำเร็จ', 'ตั้งรหัส PIN เรียบร้อยแล้ว');
      } else {
        Get.snackbar('ผิดพลาด', 'รหัสไม่ตรงกัน กรุณาลองใหม่');
        enteredPin.value = '';
      }
    }
  }

  void goBackToSetPin() {
    isConfirmMode.value = false;
    enteredPin.value = '';
    firstPin.value = '';
  }

  Future<void> registerUser() async {
    // ดึง Controller ทั้งหมดที่เก็บข้อมูลไว้
    final phoneCtrl = Get.find<PhonenumberController>();
    final infoCtrl = Get.find<InfoController>();

    // รวมร่างข้อมูลเป็น JSON ก้อนเดียว
    Map<String, dynamic> finalRegistrationData = {
      "phoneNumber": phoneCtrl.phoneNumber.value, // จากหน้าแรก
      ...infoCtrl.toJson(), // จากหน้าข้อมูลส่วนตัว (ID Card, ชื่อ, อีเมล)
      "pin": enteredPin.value, // จากหน้าตั้งรหัส PIN
    };

    print("ข้อมูลที่จะส่งไป Spring Boot: $finalRegistrationData");

    // ยิง API
    // await sendToSpringBoot(finalRegistrationData);
  }
}
