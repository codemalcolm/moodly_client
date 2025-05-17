import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CustomImageSelector {
  static Future<File?> pickSingleImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 80,
    );
    if (picked != null) {
      return File(picked.path);
    }
    return null;
  }
}
