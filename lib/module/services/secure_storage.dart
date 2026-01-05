import 'package:flutter_secure_storage/flutter_secure_storage.dart';


AndroidOptions _getAndroidOptions() => const AndroidOptions(
      encryptedSharedPreferences: false, // ปรับเป็น false สำหรับ Emulator
    );

final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());
Future<void> saveRegisterStatus(String mobile) async {
  // ต้องมี async ตรงนี้
  await storage.write(key: 'isRegistered', value: 'true');
  await storage.write(key: 'userMobile', value: mobile);
}
