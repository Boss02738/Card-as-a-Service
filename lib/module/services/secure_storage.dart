import 'package:flutter_secure_storage/flutter_secure_storage.dart';

AndroidOptions _getAndroidOptions() => const AndroidOptions(
      encryptedSharedPreferences: true,
      // บังคับใช้ AES-GCM ซึ่งปลอดภัยกว่า CBC และป้องกัน Padding Oracle Attack ได้
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_PKCS1Padding,
    );

final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());
Future<void> saveRegisterStatus(String mobile) async {
  // ต้องมี async ตรงนี้
  await storage.write(key: 'isRegistered', value: 'true');
  await storage.write(key: 'userMobile', value: mobile);
}
