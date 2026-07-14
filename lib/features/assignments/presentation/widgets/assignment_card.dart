import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/models/assignment_model.dart';
import '../providers/assignment_provider.dart';

import 'priority_chip.dart';
import 'status_chip.dart';

class AssignmentCard extends ConsumerWidget {
  final AssignmentModel assignment;

  const AssignmentCard({super.key, required this.assignment});

  Future<void> _toggleCompleted(WidgetRef ref) async {
    final repo = ref.read(assignmentRepositoryProvider);

    final newStatus = assignment.status == AssignmentStatus.completed
        ? AssignmentStatus.pending
        : AssignmentStatus.completed;

    await repo.updateAssignment(
      assignment.copyWith(status: newStatus, updatedAt: Timestamp.now()),
    );
  }

  Future<void> _delete(WidgetRef ref) async {
    await ref
        .read(assignmentRepositoryProvider)
        .deleteAssignment(assignment.id);
  }

  Color _progressColor() {
    if (assignment.progress >= 100) return Colors.green;
    if (assignment.progress >= 60) return Colors.orange;
    return Colors.blue;
  }

  String _getDaysRemaining() {
    final now = DateTime.now();
    final due = assignment.dueDate.toDate();
    final difference = due.difference(now).inDays;

    if (difference < 0) return '${difference.abs()}d overdue';
    if (difference == 0) return 'Due today';
    if (difference == 1) return '1d left';
    return '${difference}d left';
  }

  Color _getDaysRemainingColor() {
    final now = DateTime.now();
    final due = assignment.dueDate.toDate();
    final difference = due.difference(now).inDays;

    if (difference < 0) return Colors.red;
    if (difference <= 2) return Colors.orange;
    return Colors.green;
  }

  String _formatDate(Timestamp timestamp) {
    return DateFormat('MMM dd').format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted = assignment.status == AssignmentStatus.completed;
    final daysRemaining = _getDaysRemaining();
    final daysColor = _getDaysRemainingColor();

    return Dismissible(
      key: ValueKey(assignment.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 32),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder: (dialogContext) {
                return AlertDialog(
                  title: const Text("Delete Assignment?"),
                  content: const Text("This action cannot be undone."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: const Text("Cancel"),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      child: const Text("Delete"),
                    ),
                  ],
                );
              },
            ) ??
            false;
      },
      onDismissed: (_) async {
        await _delete(ref);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Assignment deleted"),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: InkWell(
          onTap: () {
            context.push('/edit-assignment', extra: assignment);
          },
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        _getTypeIcon(assignment.type),
                        size: 16,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Title
                    Expanded(
                      child: Text(
                        assignment.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: isCompleted ? Colors.grey : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Check button (smaller)
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        isCompleted
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: isCompleted ? Colors.green : Colors.grey,
                        size: 22,
                      ),
                      onPressed: () => _toggleCompleted(ref),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    Icon(Icons.school, size: 12, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        assignment.course,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(assignment.dueDate),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    PriorityChip(priority: assignment.priority, compact: true),
                    StatusChip(status: assignment.status, compact: true),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: daysColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            assignment.dueDate.toDate().isBefore(DateTime.now())
                                ? Icons.warning_amber_rounded
                                : Icons.timer_outlined,
                            size: 10,
                            color: daysColor,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            daysRemaining,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              color: daysColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Difficulty badge (compact)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(
                          assignment.difficulty,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        assignment.difficulty.name[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: _getDifficultyColor(assignment.difficulty),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: assignment.progress / 100,
                          color: _progressColor(),
                          backgroundColor: Colors.grey.shade200,
                          minHeight: 4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${assignment.progress}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _progressColor(),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 11,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${assignment.estimatedHours.toStringAsFixed(1)}h',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),

                    if (assignment.checklist.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.checklist,
                            size: 11,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${assignment.checklist.where((item) => item.completed).length}/${assignment.checklist.length}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),

                    if (assignment.attachments.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.attach_file,
                            size: 11,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${assignment.attachments.length}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),

                    Text(
                      assignment.difficulty.name,
                      style: TextStyle(
                        fontSize: 9,
                        color: _getDifficultyColor(assignment.difficulty),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(AssignmentType type) {
    switch (type) {
      case AssignmentType.homework:
        return Icons.home_work;
      case AssignmentType.lab:
        return Icons.science;
      case AssignmentType.quiz:
        return Icons.quiz;
      case AssignmentType.presentation:
        return Icons.present_to_all;
      case AssignmentType.project:
        return Icons.folder_sharp;
      case AssignmentType.exam:
        return Icons.assignment;
      case AssignmentType.custom:
        return Icons.add_task;
    }
  }

  Color _getDifficultyColor(AssignmentDifficulty difficulty) {
    switch (difficulty) {
      case AssignmentDifficulty.easy:
        return Colors.green;
      case AssignmentDifficulty.medium:
        return Colors.orange;
      case AssignmentDifficulty.hard:
        return Colors.red;
    }
  }
}
