import 'package:flutter/material.dart';

import '../../data/models/assignment_model.dart';

class StatusChip extends StatelessWidget {
  final AssignmentStatus status;
  final bool compact;

  const StatusChip({super.key, required this.status, this.compact = false});

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
    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.task_alt, size: 10, color: color),
            const SizedBox(width: 2),
            Text(
              status.name,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      );
    }

    return Chip(
      avatar: const Icon(Icons.task_alt, size: 16),
      label: Text(status.name),
      backgroundColor: color.withValues(alpha: 0.15),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
    );
  }
}
