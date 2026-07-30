import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../../data/models/assignment_model.dart';
import '../providers/assignment_provider.dart';
import '../widgets/assignment_form.dart';

class EditAssignmentScreen extends ConsumerStatefulWidget {
  final AssignmentModel assignment;

  const EditAssignmentScreen({super.key, required this.assignment});

  @override
  ConsumerState<EditAssignmentScreen> createState() =>
      _EditAssignmentScreenState();
}

class _EditAssignmentScreenState extends ConsumerState<EditAssignmentScreen> {
  bool _isLoading = false;

  Future<void> _handleSubmit(AssignmentModel updatedAssignment) async {
    setState(() => _isLoading = true);

    try {
      final repo = ref.read(assignmentRepositoryProvider);

      // Update the assignment with the new data
      final finalAssignment = updatedAssignment.copyWith(
        id: widget.assignment.id,
        updatedAt: Timestamp.now(),
      );

      await repo.updateAssignment(finalAssignment);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Assignment updated successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update assignment: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Edit Assignment",
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : AssignmentForm(
              assignment: widget.assignment,
              ownerId: widget.assignment.ownerId,
              onSubmit: _handleSubmit,
            ),
    );
  }
}
