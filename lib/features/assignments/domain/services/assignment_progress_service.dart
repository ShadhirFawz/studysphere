import '../../data/models/assignment_model.dart';

class AssignmentProgressService {
  const AssignmentProgressService();

  int calculateProgress(AssignmentModel assignment) {
    if (!assignment.isMultiDay) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final due = assignment.dueDate.toDate();
      final dueDate = DateTime(due.year, due.month, due.day);

      if (today.isBefore(dueDate)) return 0;
      return 100;
    }

    final now = DateTime.now();
    final start = assignment.startDate.toDate();
    final end = assignment.dueDate.toDate();

    if (now.isBefore(start)) return 0;

    if (now.isAfter(end)) return 100;

    final totalDuration = end.difference(start).inMinutes;
    final elapsedDuration = now.difference(start).inMinutes;

    if (totalDuration == 0) return 0;

    final progress = (elapsedDuration / totalDuration * 100).round();
    return progress.clamp(0, 100);
  }
}
