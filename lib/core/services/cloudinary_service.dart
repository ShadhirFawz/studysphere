import 'dart:io';

import 'package:dio/dio.dart';
import 'package:studysphere/config/env_config.dart';

class CloudinaryService {
  static const String cloudName = EnvConfig.cloudinaryCloudName;
  static const String uploadPreset = EnvConfig.cloudinaryUploadPreset;

  final Dio _dio = Dio();

  Future<String> uploadFile(
    File file, {
    ProgressCallback? onSendProgress,
  }) async {
    final formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path),
      "upload_preset": uploadPreset,
    });

    final response = await _dio.post(
      "https://api.cloudinary.com/v1_1/$cloudName/auto/upload",
      data: formData,
      onSendProgress: onSendProgress,
    );

    return response.data["secure_url"];
  }

  Future<List<String>> uploadFiles(
    List<File> files, {
    required Function(int current, int total, double progress) onProgress,
  }) async {
    final List<String> urls = [];
    int completed = 0;

    for (final file in files) {
      final url = await uploadFile(
        file,
        onSendProgress: (sent, total) {
          final progress = sent / total;
          onProgress(completed, files.length, progress);
        },
      );
      urls.add(url);
      completed++;
      onProgress(completed, files.length, 1.0);
    }

    return urls;
  }
}
