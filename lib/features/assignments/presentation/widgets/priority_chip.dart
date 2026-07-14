import 'package:flutter/material.dart';

import '../../data/models/assignment_model.dart';

class PriorityChip extends StatelessWidget {
  final AssignmentPriority priority;
  final bool compact;

  const PriorityChip({super.key, required this.priority, this.compact = false});

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
            Icon(Icons.flag, size: 10, color: color),
            const SizedBox(width: 2),
            Text(
              priority.name.toUpperCase(),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      );
    }

    return Chip(
      avatar: const Icon(Icons.flag, size: 16),
      label: Text(priority.name.toUpperCase()),
      backgroundColor: color.withValues(alpha: 0.15),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
    );
  }
}
