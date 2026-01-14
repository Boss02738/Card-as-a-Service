import 'package:get/get.dart';
import 'package:flutter/material.dart';

class AddressController extends GetxController {
  final addressCtrl = TextEditingController();
  final districtCtrl = TextEditingController();
  final subdistrictCtrl = TextEditingController();
  final provincetCtrl = TextEditingController();
  final zipcodeCtrl = TextEditingController();
  var isLoading = false.obs;

  Map<String, dynamic> toJson() {
    return {
      "address": addressCtrl.text,
      "subdistrict": subdistrictCtrl.text,
      "district": districtCtrl.text,
      "province": provincetCtrl.text,
      "zipcode": zipcodeCtrl.text,
      "pin": "123456",
      "deviceId": "DEVICE-UUID-999",
    };
  }
}
