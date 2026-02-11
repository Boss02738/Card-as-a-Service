import 'package:flutter_secure_storage/flutter_secure_storage.dart';


AndroidOptions _getAndroidOptions() => const AndroidOptions(
      encryptedSharedPreferences: true,
      // บังคับให้ใช้ Key ในระดับ Hardware (ถ้าเครื่องรองรับ) 
      // จะช่วยกำจัดตัวแดงเรื่องการเก็บกุญแจไม่ปลอดภัยได้
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_PKCS1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    );

final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());
Future<void> saveRegisterStatus(String mobile) async {
  // ต้องมี async ตรงนี้
  await storage.write(key: 'isRegistered', value: 'true');
  await storage.write(key: 'userMobile', value: mobile);
}
