import 'package:flutter/material.dart';

import '../../data/models/assignment_model.dart';

class StatusChip extends StatelessWidget {
  final AssignmentStatus status;

  const StatusChip({super.key, required this.status});

  Color get color {
    switch (status) {
      case AssignmentStatus.draft:
        return Colors.grey;

      case AssignmentStatus.pending:
        return Colors.orange;

      case AssignmentStatus.inProgress:
        return Colors.blue;

      case AssignmentStatus.submitted:
        return Colors.teal;

      case AssignmentStatus.completed:
        return Colors.green;

      case AssignmentStatus.cancelled:
        return Colors.red;

      case AssignmentStatus.overdue:
        return Colors.deepOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: const Icon(Icons.task_alt, size: 16),
      label: Text(status.name),
      backgroundColor: color.withValues(alpha: 0.15),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
    );
  }
}
