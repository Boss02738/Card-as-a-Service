 import 'package:get/get.dart';

String getDeviceSizeCategory() {
    double width = Get.context!.width; 
    if (width < 100) {
      return 'image_small';
    } else if (width < 300) {
      return 'image_medium';
    } else {
      return 'image_large';
    }
  }