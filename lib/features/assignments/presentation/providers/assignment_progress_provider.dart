import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/services/assignment_progress_service.dart';

final assignmentProgressProvider = Provider<AssignmentProgressService>((ref) {
  return AssignmentProgressService();
});
