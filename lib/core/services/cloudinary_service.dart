import 'dart:io';

import 'package:dio/dio.dart';
import 'package:studysphere/config/env_config.dart';

class CloudinaryService {
  static const String cloudName = EnvConfig.cloudinaryCloudName;
  static const String uploadPreset = EnvConfig.cloudinaryUploadPreset;

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
