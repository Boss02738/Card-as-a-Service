import 'package:app_device_integrity/app_device_integrity.dart';

class IntegrityService {
  static const String _cloudProjectNumber = "984904758314";

  static Future<String?> requestToken(String nonce) async {
    try {
      // 1. สร้าง Instance ของ AppDeviceIntegrity
      final integrityPlugin = AppDeviceIntegrity();

      // 2. เรียกใช้ฟังก์ชันตามที่ปรากฏในภาพซอร์สโค้ดของคุณ
      // challengeString ในที่นี้คือ nonce (ค่าสุ่มจาก BE)
      // gcp คือ Project Number ที่ต้องส่งเป็น int
      final String? token = await integrityPlugin.getAttestationServiceSupport(
        challengeString: nonce,
        gcp: int.parse(_cloudProjectNumber),
      );

      print(" NovaPay Integrity Token: $token");
      return token;
    } catch (e) {
      print("❌ Integrity Error: $e");
      return null;
    }
  }
}
