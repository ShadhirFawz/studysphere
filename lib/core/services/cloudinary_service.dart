import 'dart:io';

import 'package:dio/dio.dart';

class CloudinaryService {
  static const String cloudName = "YOUR_CLOUD_NAME";
  static const String uploadPreset = "YOUR_UPLOAD_PRESET";

  final Dio _dio = Dio();

  Future<String> uploadFile(File file) async {
    final formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path),
      "upload_preset": uploadPreset,
    });

    final response = await _dio.post(
      "https://api.cloudinary.com/v1_1/$cloudName/auto/upload",
      data: formData,
    );

    return response.data["secure_url"];
  }
}
