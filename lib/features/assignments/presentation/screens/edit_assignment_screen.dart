import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../../data/models/assignment_model.dart';
import '../providers/assignment_provider.dart';

class EditAssignmentScreen extends ConsumerStatefulWidget {
  final AssignmentModel assignment;

  const EditAssignmentScreen({super.key, required this.assignment});

  @override
  ConsumerState<EditAssignmentScreen> createState() =>
      _EditAssignmentScreenState();
}

class _EditAssignmentScreenState extends ConsumerState<EditAssignmentScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController courseController;

  late String priority;
  late String status;
  DateTime? dueDate; // Changed from late to nullable

  bool loading = false;

  @override
  void initState() {
    super.initState();

    final a = widget.assignment;

    titleController = TextEditingController(text: a.title);
    descriptionController = TextEditingController(text: a.description);
    courseController = TextEditingController(text: a.course);

    priority = a.priority;
    status = a.status;
    dueDate = a.dueDate.toDate();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    courseController.dispose();
    super.dispose();
  }

  Future<void> updateAssignment() async {
    if (titleController.text.isEmpty || dueDate == null) return;

    setState(() => loading = true);

    final repo = ref.read(assignmentRepositoryProvider);

    final updated = widget.assignment.copyWith(
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      course: courseController.text.trim(),
      priority: priority,
      status: status,
      dueDate: Timestamp.fromDate(dueDate!),
      updatedAt: Timestamp.now(),
    );

    await repo.updateAssignment(updated);

    setState(() => loading = false);

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Edit Assignment",
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title Field
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // Description Field
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 12),

            // Course Field
            TextField(
              controller: courseController,
              decoration: const InputDecoration(
                labelText: "Course",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // Priority Dropdown
            DropdownButtonFormField<String>(
              value: priority,
              items: AssignmentPriority.values
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  priority = val!;
                });
              },
              decoration: const InputDecoration(
                labelText: "Priority",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // Status Dropdown
            DropdownButtonFormField<String>(
              value: status,
              items: AssignmentStatus.values
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  status = val!;
                });
              },
              decoration: const InputDecoration(
                labelText: "Status",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // Due Date Picker
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

            // Save Changes Button
            ElevatedButton(
              onPressed: loading ? null : updateAssignment,
              child: Text(loading ? "Saving..." : "Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
