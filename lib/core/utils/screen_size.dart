 import 'package:get/get.dart';

String getDeviceSizeCategory() {
    double width = Get.context!.width; 
    if (width < 300) {
      return 'image_small';
    } else if (width < 500) {
      return 'image_medium';
    } else {
      return 'image_large';
    }
  }