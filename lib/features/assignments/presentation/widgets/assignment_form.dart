import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../data/models/assignment_checklist_item.dart';
import '../../data/models/assignment_model.dart';
import '../../data/models/assignment_tag.dart';

class AssignmentForm extends StatefulWidget {
  final AssignmentModel? assignment;
  final Function(AssignmentModel) onSubmit;
  final String ownerId;

  const AssignmentForm({
    super.key,
    required this.ownerId,
    required this.onSubmit,
    this.assignment,
  });

  @override
  State<AssignmentForm> createState() => _AssignmentFormState();
}

class _AssignmentFormState extends State<AssignmentForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  late final TextEditingController courseController;
  late final TextEditingController notesController;
  late final TextEditingController estimatedHoursController;

  AssignmentType type = AssignmentType.homework;
  AssignmentPriority priority = AssignmentPriority.medium;
  AssignmentStatus status = AssignmentStatus.pending;
  AssignmentDifficulty difficulty = AssignmentDifficulty.medium;

  DateTime startDate = DateTime.now();
  DateTime dueDate = DateTime.now().add(const Duration(days: 7));

  @override
  void initState() {
    super.initState();

    final assignment = widget.assignment;

    titleController = TextEditingController(text: assignment?.title ?? "");

    descriptionController = TextEditingController(
      text: assignment?.description ?? "",
    );

    courseController = TextEditingController(text: assignment?.course ?? "");

    notesController = TextEditingController(text: assignment?.notes ?? "");

    estimatedHoursController = TextEditingController(
      text: assignment?.estimatedHours.toString() ?? "1",
    );

    if (assignment != null) {
      type = assignment.type;
      priority = assignment.priority;
      status = assignment.status;
      difficulty = assignment.difficulty;

      startDate = assignment.startDate.toDate();
      dueDate = assignment.dueDate.toDate();
    }
  }

  Future<void> pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
      initialDate: startDate,
    );

    if (picked != null) {
      setState(() {
        startDate = picked;
      });
    }
  }

  Future<void> pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: startDate,
      lastDate: DateTime(2100),
      initialDate: dueDate,
    );

    if (picked != null) {
      setState(() {
        dueDate = picked;
      });
    }
  }

  void submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final now = Timestamp.now();

    final assignment = AssignmentModel(
      id: widget.assignment?.id ?? "",
      ownerId: widget.ownerId,
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      course: courseController.text.trim(),
      type: type,
      priority: priority,
      status: status,
      difficulty: difficulty,
      progress: widget.assignment?.progress ?? 0,
      estimatedHours: double.tryParse(estimatedHoursController.text) ?? 1,
      startDate: Timestamp.fromDate(startDate),
      dueDate: Timestamp.fromDate(dueDate),
      checklist: widget.assignment?.checklist ?? <AssignmentChecklistItem>[],
      tags: widget.assignment?.tags ?? <AssignmentTag>[],
      notes: notesController.text.trim(),
      createdAt: widget.assignment?.createdAt ?? now,
      updatedAt: now,
    );

    widget.onSubmit(assignment);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          TextFormField(
            controller: titleController,
            decoration: const InputDecoration(labelText: "Title"),
            validator: (v) => v == null || v.isEmpty ? "Required" : null,
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: descriptionController,
            decoration: const InputDecoration(labelText: "Description"),
            maxLines: 3,
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: courseController,
            decoration: const InputDecoration(labelText: "Course"),
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<AssignmentType>(
            value: type,
            decoration: const InputDecoration(labelText: "Type"),
            items: AssignmentType.values
                .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                .toList(),
            onChanged: (v) {
              setState(() {
                type = v!;
              });
            },
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<AssignmentPriority>(
            value: priority,
            decoration: const InputDecoration(labelText: "Priority"),
            items: AssignmentPriority.values
                .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                .toList(),
            onChanged: (v) {
              setState(() {
                priority = v!;
              });
            },
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<AssignmentStatus>(
            value: status,
            decoration: const InputDecoration(labelText: "Status"),
            items: AssignmentStatus.values
                .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                .toList(),
            onChanged: (v) {
              setState(() {
                status = v!;
              });
            },
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<AssignmentDifficulty>(
            value: difficulty,
            decoration: const InputDecoration(labelText: "Difficulty"),
            items: AssignmentDifficulty.values
                .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                .toList(),
            onChanged: (v) {
              setState(() {
                difficulty = v!;
              });
            },
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: estimatedHoursController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Estimated Hours"),
          ),

          const SizedBox(height: 20),

          ListTile(
            title: Text(
              "Start : ${startDate.toLocal().toString().split(' ')[0]}",
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: pickStartDate,
          ),

          ListTile(
            title: Text("Due : ${dueDate.toLocal().toString().split(' ')[0]}"),
            trailing: const Icon(Icons.calendar_month),
            onTap: pickDueDate,
          ),

          const SizedBox(height: 20),

          TextFormField(
            controller: notesController,
            maxLines: 5,
            decoration: const InputDecoration(labelText: "Notes"),
          ),

          const SizedBox(height: 30),

          FilledButton(
            onPressed: submit,
            child: Text(
              widget.assignment == null ? "Create Assignment" : "Save Changes",
            ),
          ),
        ],
      ),
    );
  }
}
