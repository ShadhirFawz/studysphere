import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

import '../providers/cloudinary_provider.dart';
import '../widgets/attachment_picker.dart';
import '../../data/models/assignment_attachment.dart';
import '../../data/models/assignment_checklist_item.dart';
import '../../data/models/assignment_model.dart';
import '../../data/models/assignment_tag.dart';
import 'assignment_attachment_card.dart';

class AssignmentForm extends ConsumerStatefulWidget {
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
  ConsumerState<AssignmentForm> createState() => _AssignmentFormState();
}

class _AssignmentFormState extends ConsumerState<AssignmentForm> {
  final _formKey = GlobalKey<FormState>();
  List<File> selectedFiles = [];

  List<AssignmentAttachment> uploadedAttachments = [];

  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  late final TextEditingController courseController;
  late final TextEditingController notesController;
  late final TextEditingController estimatedHoursController;

  AssignmentType type = AssignmentType.homework;
  AssignmentPriority priority = AssignmentPriority.medium;
  AssignmentStatus status = AssignmentStatus.pending;
  AssignmentDifficulty difficulty = AssignmentDifficulty.medium;

  bool isMultiDay = false; // Default: disabled (single day)
  DateTime selectedDate = DateTime.now();
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
      isMultiDay = assignment.isMultiDay;
      type = assignment.type;
      priority = assignment.priority;
      status = assignment.status;
      difficulty = assignment.difficulty;

      startDate = assignment.startDate.toDate();
      dueDate = assignment.dueDate.toDate();
      selectedDate = startDate;
    }

    uploadedAttachments = List.from(widget.assignment?.attachments ?? []);
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    courseController.dispose();
    notesController.dispose();
    estimatedHoursController.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
      initialDate: selectedDate,
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        if (!isMultiDay) {
          // For single day, both start and due are the same
          startDate = picked;
          dueDate = picked;
        } else {
          // For multi-day, update start date
          startDate = picked;
          if (dueDate.isBefore(startDate)) {
            dueDate = startDate.add(const Duration(days: 7));
          }
        }
      });
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
        if (dueDate.isBefore(startDate)) {
          dueDate = startDate.add(const Duration(days: 7));
        }
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

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final now = Timestamp.now();

    if (selectedFiles.isNotEmpty) {
      final uploader = ref.read(cloudinaryProvider);

      for (final file in selectedFiles) {
        final url = await uploader.uploadFile(file);

        uploadedAttachments.add(
          AssignmentAttachment(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            fileName: file.path.split('/').last,
            fileUrl: url,
            fileType: file.path.split('.').last.toLowerCase(),
            fileSize: await file.length(),
            uploadedBy: widget.ownerId,
            uploadedAt: Timestamp.now(),
          ),
        );
      }
    }

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
      estimatedHours: double.tryParse(estimatedHoursController.text) ?? 1,
      startDate: Timestamp.fromDate(isMultiDay ? startDate : selectedDate),
      dueDate: Timestamp.fromDate(isMultiDay ? dueDate : selectedDate),
      isMultiDay: isMultiDay,
      checklist: widget.assignment?.checklist ?? <AssignmentChecklistItem>[],
      tags: widget.assignment?.tags ?? <AssignmentTag>[],
      notes: notesController.text.trim(),
      attachments: uploadedAttachments,
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
          // Title Field
          TextFormField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: "Title",
              border: OutlineInputBorder(),
            ),
            validator: (v) => v == null || v.isEmpty ? "Required" : null,
          ),

          const SizedBox(height: 16),

          // Description Field
          TextFormField(
            controller: descriptionController,
            decoration: const InputDecoration(
              labelText: "Description",
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),

          const SizedBox(height: 16),

          // Course Field
          TextFormField(
            controller: courseController,
            decoration: const InputDecoration(
              labelText: "Course",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          // Type Dropdown
          DropdownButtonFormField<AssignmentType>(
            initialValue: type,
            decoration: const InputDecoration(
              labelText: "Type",
              border: OutlineInputBorder(),
            ),
            items: AssignmentType.values
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(_capitalize(e.name)),
                  ),
                )
                .toList(),
            onChanged: (v) {
              setState(() {
                type = v!;
              });
            },
          ),

          const SizedBox(height: 16),

          // Priority Dropdown
          DropdownButtonFormField<AssignmentPriority>(
            initialValue: priority,
            decoration: const InputDecoration(
              labelText: "Priority",
              border: OutlineInputBorder(),
            ),
            items: AssignmentPriority.values
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(_capitalize(e.name)),
                  ),
                )
                .toList(),
            onChanged: (v) {
              setState(() {
                priority = v!;
              });
            },
          ),

          const SizedBox(height: 16),

          // Status Dropdown
          DropdownButtonFormField<AssignmentStatus>(
            initialValue: status,
            decoration: const InputDecoration(
              labelText: "Status",
              border: OutlineInputBorder(),
            ),
            items: AssignmentStatus.values
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(_capitalize(e.name)),
                  ),
                )
                .toList(),
            onChanged: (v) {
              setState(() {
                status = v!;
              });
            },
          ),

          const SizedBox(height: 16),

          // Difficulty Dropdown
          DropdownButtonFormField<AssignmentDifficulty>(
            initialValue: difficulty,
            decoration: const InputDecoration(
              labelText: "Difficulty",
              border: OutlineInputBorder(),
            ),
            items: AssignmentDifficulty.values
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(_capitalize(e.name)),
                  ),
                )
                .toList(),
            onChanged: (v) {
              setState(() {
                difficulty = v!;
              });
            },
          ),

          const SizedBox(height: 16),

          // Estimated Hours
          TextFormField(
            controller: estimatedHoursController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Estimated Hours",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 20),

          // Multi-Day Toggle (Default: OFF)
          SwitchListTile(
            title: const Text(
              "Multi-Day Assignment",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              isMultiDay
                  ? "Enable start and end dates"
                  : "Single day task (toggle to enable date range)",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            value: isMultiDay,
            activeColor: Colors.blue,
            onChanged: (value) {
              setState(() {
                isMultiDay = value;
                if (!isMultiDay) {
                  // When toggling off, set both dates to the same day
                  dueDate = selectedDate;
                  startDate = selectedDate;
                } else {
                  // When toggling on, set due date to start + 7 days
                  if (startDate.isAtSameMomentAs(dueDate)) {
                    dueDate = startDate.add(const Duration(days: 7));
                  }
                }
              });
            },
          ),

          const SizedBox(height: 16),

          // Date Picker Section
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // If NOT multi-day: Show single date picker
                  if (!isMultiDay)
                    ListTile(
                      title: Text(
                        "Date: ${selectedDate.toLocal().toString().split(' ')[0]}",
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      leading: const Icon(
                        Icons.calendar_today,
                        color: Colors.blue,
                      ),
                      onTap: pickDate,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      tileColor: Colors.grey.shade50,
                    ),

                  // If multi-day: Show both start and due dates
                  if (isMultiDay) ...[
                    ListTile(
                      title: Text(
                        "Start Date: ${startDate.toLocal().toString().split(' ')[0]}",
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      leading: const Icon(
                        Icons.calendar_today,
                        color: Colors.blue,
                      ),
                      onTap: pickStartDate,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      tileColor: Colors.grey.shade50,
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      title: Text(
                        "Due Date: ${dueDate.toLocal().toString().split(' ')[0]}",
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      leading: const Icon(
                        Icons.calendar_month,
                        color: Colors.orange,
                      ),
                      onTap: pickDueDate,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      tileColor: Colors.grey.shade50,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Progress info for multi-day tasks
          if (isMultiDay) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.timeline, size: 18, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Progress updates automatically based on time elapsed",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Current Attachments
          if (uploadedAttachments.isNotEmpty) ...[
            const Text(
              "Current Attachments",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            ...uploadedAttachments.asMap().entries.map((entry) {
              final index = entry.key;
              final file = entry.value;

              return AssignmentAttachmentCard(
                attachment: file,
                onDelete: () {
                  setState(() {
                    uploadedAttachments.removeAt(index);
                  });
                },
              );
            }),
            const SizedBox(height: 20),
          ],

          // Attachment Picker
          AttachmentPicker(
            onChanged: (files) {
              selectedFiles = files;
            },
          ),

          const SizedBox(height: 24),

          // Notes Field
          TextFormField(
            controller: notesController,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: "Notes",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 30),

          // Submit Button
          FilledButton(
            onPressed: submit,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              widget.assignment == null ? "Create Assignment" : "Save Changes",
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
