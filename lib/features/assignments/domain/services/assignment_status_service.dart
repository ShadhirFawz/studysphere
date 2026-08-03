import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/assignment_model.dart';

class AssignmentStatusService {
  const AssignmentStatusService();

  /// Calculate the appropriate status based on dates and current status
  String getAutoStatus(AssignmentModel assignment) {
    final now = DateTime.now();
    final startDate = assignment.startDate.toDate();
    final dueDate = assignment.dueDate.toDate();

    // If status is manually set to completed or cancelled, keep it
    if (assignment.status == AssignmentStatus.completed ||
        assignment.status == AssignmentStatus.cancelled) {
      return assignment.status.name;
    }

    // Check if overdue
    if (now.isAfter(dueDate) &&
        assignment.status != AssignmentStatus.completed) {
      return AssignmentStatus.overdue.name;
    }

    // Check if not started yet
    if (now.isBefore(startDate)) {
      return AssignmentStatus.draft.name;
    }

    // Check if in progress (between start and due date)
    if (now.isAfter(startDate) && now.isBefore(dueDate)) {
      return AssignmentStatus.inProgress.name;
    }

    // Default to pending
    return AssignmentStatus.pending.name;
  }

  /// Check if status should be auto-updated
  bool shouldAutoUpdateStatus(AssignmentModel assignment) {
    // Don't auto-update if status is manually set to completed or cancelled
    if (assignment.status == AssignmentStatus.completed ||
        assignment.status == AssignmentStatus.cancelled) {
      return false;
    }
    return true;
  }

  /// Get status display color
  Color getStatusColor(AssignmentStatus status) {
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

  /// Get status display icon
  IconData getStatusIcon(AssignmentStatus status) {
    switch (status) {
      case AssignmentStatus.draft:
        return Icons.drafts;
      case AssignmentStatus.pending:
        return Icons.pending;
      case AssignmentStatus.inProgress:
        return Icons.play_circle;
      case AssignmentStatus.submitted:
        return Icons.send;
      case AssignmentStatus.completed:
        return Icons.check_circle;
      case AssignmentStatus.cancelled:
        return Icons.cancel;
      case AssignmentStatus.overdue:
        return Icons.warning;
    }
  }

  /// Get status display text with emoji
  String getStatusDisplayText(AssignmentStatus status) {
    switch (status) {
      case AssignmentStatus.draft:
        return '📝 Draft';
      case AssignmentStatus.pending:
        return '⏳ Pending';
      case AssignmentStatus.inProgress:
        return '🔄 In Progress';
      case AssignmentStatus.submitted:
        return '📤 Submitted';
      case AssignmentStatus.completed:
        return '✅ Completed';
      case AssignmentStatus.cancelled:
        return '❌ Cancelled';
      case AssignmentStatus.overdue:
        return '⚠️ Overdue';
    }
  }
}

final assignmentStatusProvider = Provider<AssignmentStatusService>((ref) {
  return AssignmentStatusService();
});
