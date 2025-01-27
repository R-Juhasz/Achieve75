// lib/utils/image_helper.dart

import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart'; // Correct import
import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ImageHelper {
  final ImagePicker _picker = ImagePicker();

  // Request camera permission
  Future<bool> requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
      if (status.isGranted) {
        return true;
      } else {
        return false;
      }
    }
    return true;
  }

  // Capture image from camera
  Future<File?> captureImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 80, // Compress the image to 80% quality
    );

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  // Save image to app directory
  Future<String> saveImage(File image, int day) async {
    final Directory appDir = await getApplicationDocumentsDirectory(); // Correct usage
    final String picturesDirPath = '${appDir.path}/ProgressPictures';
    final Directory picturesDir = Directory(picturesDirPath);

    // Create the directory if it doesn't exist
    if (!await picturesDir.exists()) {
      await picturesDir.create(recursive: true);
    }

    // Define a unique file name using curly braces for clarity
    final String fileName = 'day_${day}_${DateTime.now().millisecondsSinceEpoch}.png';
    final String savedPath = '$picturesDirPath/$fileName';

    // Save the image to the designated path
    final File savedImage = await image.copy(savedPath);

    return savedImage.path;
  }

  // Save image data to SharedPreferences
  Future<void> saveImageData(String path, int day) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> savedPictures = prefs.getStringList('progressPictures') ?? [];
    Map<String, dynamic> pictureData = {
      'filePath': path,
      'day': day,
    };
    savedPictures.add(jsonEncode(pictureData));
    await prefs.setStringList('progressPictures', savedPictures);
  }
}
