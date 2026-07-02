import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../../data/models/assignment_model.dart';
import '../providers/assignment_provider.dart';

class AddAssignmentScreen extends ConsumerStatefulWidget {
  const AddAssignmentScreen({super.key});

  @override
  ConsumerState<AddAssignmentScreen> createState() =>
      _AddAssignmentScreenState();
}

class _AddAssignmentScreenState extends ConsumerState<AddAssignmentScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final courseController = TextEditingController();

  String priority = AssignmentPriority.medium;

  DateTime? dueDate;

  bool loading = false;

  Future<void> createAssignment() async {
    if (titleController.text.isEmpty || dueDate == null) return;

    setState(() => loading = true);

    final userId = FirebaseAuth.instance.currentUser!.uid;

    final now = Timestamp.now();

    final assignment = AssignmentModel(
      id: '',
      userId: userId,
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      course: courseController.text.trim(),
      priority: priority,
      status: AssignmentStatus.pending,
      dueDate: Timestamp.fromDate(dueDate!),
      createdAt: now,
      updatedAt: now,
    );

    await ref.read(assignmentRepositoryProvider).createAssignment(assignment);

    setState(() => loading = false);

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Add Assignment",

      body: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: "Description"),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: courseController,
              decoration: const InputDecoration(labelText: "Course"),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField(
              value: priority,
              items: AssignmentPriority.values
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  priority = val!;
                });
              },
              decoration: const InputDecoration(labelText: "Priority"),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );

                if (picked != null) {
                  setState(() {
                    dueDate = picked;
                  });
                }
              },
              child: Text(
                dueDate == null
                    ? "Pick Due Date"
                    : dueDate.toString().split(" ")[0],
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: loading ? null : createAssignment,
              child: Text(loading ? "Saving..." : "Create Assignment"),
            ),
          ],
        ),
      ),
    );
  }
}
