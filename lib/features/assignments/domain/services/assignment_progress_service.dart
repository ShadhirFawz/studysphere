import '../../data/models/assignment_model.dart';

class AssignmentProgressService {
  const AssignmentProgressService();

  /// Calculate auto-progress based on time elapsed between start and end dates
  int calculateProgress(AssignmentModel assignment) {
    // If completed, return 100%
    if (assignment.status == AssignmentStatus.completed) {
      return 100;
    }

    // If cancelled, return 0%
    if (assignment.status == AssignmentStatus.cancelled) {
      return 0;
    }

    if (!assignment.isMultiDay) {
      // For single-day tasks
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final due = assignment.dueDate.toDate();
      final dueDate = DateTime(due.year, due.month, due.day);

      if (today.isBefore(dueDate)) return 0;

      // If overdue and not completed, cap at 90%
      if (now.isAfter(due) && assignment.status != AssignmentStatus.completed) {
        return 90;
      }

      return 100;
    }

    final now = DateTime.now();
    final start = assignment.startDate.toDate();
    final end = assignment.dueDate.toDate();

    // If task hasn't started yet
    if (now.isBefore(start)) return 0;

    // If task is overdue, cap at 90%
    if (now.isAfter(end) && assignment.status != AssignmentStatus.completed) {
      return 90;
    }

    // Calculate progress based on time elapsed
    final totalDuration = end.difference(start).inMinutes;
    final elapsedDuration = now.difference(start).inMinutes;

    if (totalDuration == 0) return 0;

    final progress = (elapsedDuration / totalDuration * 100).round();
    return progress.clamp(0, 100);
  }
}
