import 'package:flutter/material.dart';

import '../../data/models/assignment_model.dart';

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  Color getColor() {
    switch (status) {
      case AssignmentStatus.completed:
        return Colors.green;
      case AssignmentStatus.inProgress:
        return Colors.blue;
      case AssignmentStatus.pending:
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(status),
      backgroundColor: getColor().withValues(alpha: 0.2),
      labelStyle: TextStyle(color: getColor()),
    );
  }
}
