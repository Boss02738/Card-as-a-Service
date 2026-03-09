import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CameraService {
  final ImagePicker _picker = ImagePicker();

  // ฟังก์ชันกลางสำหรับการถ่ายรูป
  Future<File?> takePicture() async {
    try {
      // final XFile? photo = await _picker.pickImage(
      //   source: ImageSource.camera,
      //   preferredCameraDevice: CameraDevice.rear,
      // );
      // แก้ไขใน CameraService.dart
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: 1024, // จำกัดความกว้าง
        maxHeight: 1024, // จำกัดความสูง
        imageQuality:
            80, // ลดคุณภาพลงเล็กน้อยเหลือ 80% (ตาแยกไม่ออก แต่ไฟล์เล็กลงมาก)
      );
      if (photo != null) {
        return File(photo.path);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
