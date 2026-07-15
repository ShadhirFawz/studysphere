class AssignmentProgressService {
  const AssignmentProgressService();

  int calculateProgress({
    required DateTime now,
    required DateTime startDate,
    required DateTime dueDate,
    required bool isMultiDay,
  }) {
    if (!isMultiDay) {
      if (now.isBefore(dueDate)) {
        return 0;
      }

      return 100;
    }

    if (now.isBefore(startDate)) {
      return 0;
    }

    if (now.isAfter(dueDate)) {
      return 100;
    }

    final total = dueDate.difference(startDate).inSeconds;

    if (total <= 0) {
      return 100;
    }

    final elapsed = now.difference(startDate).inSeconds;

    return ((elapsed / total) * 100).clamp(0, 100).round();
  }
}
