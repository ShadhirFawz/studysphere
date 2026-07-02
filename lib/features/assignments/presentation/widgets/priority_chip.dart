import 'package:flutter/material.dart';

import '../../data/models/assignment_model.dart';

class PriorityChip extends StatelessWidget {
  final String priority;

  const PriorityChip({super.key, required this.priority});

  Color getColor() {
    switch (priority) {
      case AssignmentPriority.high:
        return Colors.red;
      case AssignmentPriority.medium:
        return Colors.orange;
      case AssignmentPriority.low:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(priority),
      backgroundColor: getColor().withOpacity(0.2),
      labelStyle: TextStyle(color: getColor()),
    );
  }
}
