import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(assignment.id),

      direction: DismissDirection.endToStart,

      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Assignment deleted")));
        }
      },

      child: Card(
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),

          onTap: () {
            context.push('/edit-assignment', extra: assignment);
          },

          title: Text(
            assignment.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              decoration: assignment.status == AssignmentStatus.completed
                  ? TextDecoration.lineThrough
                  : null,
            ),
          ),

          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              Text(assignment.course),

              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  PriorityChip(priority: assignment.priority),
                  StatusChip(status: assignment.status),
                ],
              ),

              const SizedBox(height: 12),

              LinearProgressIndicator(
                value: assignment.progress / 100,
                color: _progressColor(),
              ),

              const SizedBox(height: 4),

              Text(
                "${assignment.progress}% completed",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),

          trailing: IconButton(
            icon: Icon(
              assignment.status == AssignmentStatus.completed
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: assignment.status == AssignmentStatus.completed
                  ? Colors.green
                  : Colors.grey,
            ),
            onPressed: () {
              _toggleCompleted(ref);
            },
          ),
        ),
      ),
    );
  }
}
