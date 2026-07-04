import 'package:flutter/material.dart';

import '../../data/models/assignment_model.dart';

class PriorityChip extends StatelessWidget {
  final AssignmentPriority priority;

  const PriorityChip({super.key, required this.priority});

  Color get color {
    switch (priority) {
      case AssignmentPriority.low:
        return Colors.green;

      case AssignmentPriority.medium:
        return Colors.orange;

      case AssignmentPriority.high:
        return Colors.red;

      case AssignmentPriority.critical:
        return Colors.deepPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: const Icon(Icons.flag, size: 16),
      label: Text(priority.name.toUpperCase()),
      backgroundColor: color.withValues(alpha: 0.15),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
    );
  }
}
