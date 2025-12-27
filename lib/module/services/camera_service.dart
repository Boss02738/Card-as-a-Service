import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CameraService {
  final ImagePicker _picker = ImagePicker();

  // ฟังก์ชันกลางสำหรับการถ่ายรูป
  Future<File?> takePicture() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (photo != null) {
        return File(photo.path);
      }
      return null;
    } catch (e) {
      print("Error taking picture: $e");
      return null;
    }
  }
}
