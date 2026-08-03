import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/assignment_model.dart';
import 'package:studysphere/features/assignments/domain/services/assignment_status_service.dart';
import 'package:studysphere/features/assignments/presentation/providers/assignment_provider.dart';

final assignmentStatusServiceProvider = Provider<AssignmentStatusService>((
  ref,
) {
  return AssignmentStatusService();
});

/// Provider to get auto-calculated status for an assignment
final autoAssignmentStatusProvider =
    Provider.family<AssignmentStatus, AssignmentModel>((ref, assignment) {
      final statusService = ref.watch(assignmentStatusServiceProvider);
      final statusName = statusService.getAutoStatus(assignment);
      return AssignmentStatus.values.firstWhere(
        (e) => e.name == statusName,
        orElse: () => assignment.status,
      );
    });

/// Provider to check if status should be auto-updated
final shouldAutoUpdateStatusProvider = Provider.family<bool, AssignmentModel>((
  ref,
  assignment,
) {
  final statusService = ref.watch(assignmentStatusServiceProvider);
  return statusService.shouldAutoUpdateStatus(assignment);
});

/// Function to update assignment status based on dates
Future<void> updateAssignmentStatus(
  WidgetRef ref,
  AssignmentModel assignment,
) async {
  final statusService = ref.read(assignmentStatusServiceProvider);
  final repo = ref.read(assignmentRepositoryProvider);

  // Only auto-update if not manually set to completed or cancelled
  if (!statusService.shouldAutoUpdateStatus(assignment)) {
    return;
  }

  final autoStatusName = statusService.getAutoStatus(assignment);
  final autoStatus = AssignmentStatus.values.firstWhere(
    (e) => e.name == autoStatusName,
    orElse: () => assignment.status,
  );

  // Only update if status has changed
  if (autoStatus != assignment.status) {
    final updatedAssignment = assignment.copyWith(
      status: autoStatus,
      updatedAt: Timestamp.now(),
    );
    await repo.updateAssignment(updatedAssignment);
  }
}
