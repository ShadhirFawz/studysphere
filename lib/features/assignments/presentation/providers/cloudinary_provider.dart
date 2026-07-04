import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/cloudinary_service.dart';

final cloudinaryProvider = Provider<CloudinaryService>((ref) {
  return CloudinaryService();
});
