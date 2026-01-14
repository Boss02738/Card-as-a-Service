// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:my_app/module/services/secure_storage.dart';
// import 'package:my_app/module/services/secure_storage.dart';

// class ProfileController extends GetxController {
//   var email = ''.obs;
//   var phoneNumber = ''.obs;
//   var isloading = true.obs;
// Future <void> getuserInfo ()async {
//   try{
//     isloading.value = true ;

//     String? token = await storage.read(key: 'accessToken');
    
//     if (token == null) {
//         Get.offAllNamed('/login'); 
//         return;
//       }
//   }
// }

// }