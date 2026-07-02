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

  Future<void> _toggleStatus(WidgetRef ref) async {
    final repo = ref.read(assignmentRepositoryProvider);

    final updated = assignment.copyWith(
      status: assignment.status == AssignmentStatus.completed
          ? AssignmentStatus.pending
          : AssignmentStatus.completed,
      updatedAt: Timestamp.now(),
    );

    await repo.updateAssignment(updated);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(assignmentRepositoryProvider);

    await repo.deleteAssignment(assignment.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(assignment.id),
      direction: DismissDirection.endToStart,

      background: Container(
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),

      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text("Delete Assignment?"),
            content: const Text("This action cannot be undone."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text("Delete"),
              ),
            ],
          ),
        );
      },

      onDismissed: (_) async {
        try {
          await _delete(context, ref);

          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("Assignment deleted")));
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(e.toString())));
          }
        }
      },

      child: Card(
        child: ListTile(
          onTap: () {
            context.push('/edit-assignment', extra: assignment);
          },

          title: Text(
            assignment.title,
            style: TextStyle(
              decoration: assignment.status == AssignmentStatus.completed
                  ? TextDecoration.lineThrough
                  : null,
            ),
          ),

          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(assignment.course),

              const SizedBox(height: 6),

              Row(
                children: [
                  PriorityChip(priority: assignment.priority),
                  const SizedBox(width: 6),
                  StatusChip(status: assignment.status),
                ],
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
            onPressed: () => _toggleStatus(ref),
          ),
        ),
      ),
    );
  }
}
