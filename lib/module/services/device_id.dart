import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

Future<String?> getDeviceId() async {
  var deviceInfo = DeviceInfoPlugin();
  if (Platform.isIOS) {
    var iosInfo = await deviceInfo.iosInfo;
    return iosInfo.identifierForVendor; // ID สำหรับ iOS
  } else if (Platform.isAndroid) {
    var androidInfo = await deviceInfo.androidInfo;
    return androidInfo.id; // ID สำหรับ Android (มักเป็นเลข Android ID)
  }
  return null;
}