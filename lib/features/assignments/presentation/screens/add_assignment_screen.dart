import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../../data/models/assignment_model.dart';
import '../providers/assignment_provider.dart';
import '../widgets/assignment_form.dart';

class AddAssignmentScreen extends ConsumerStatefulWidget {
  const AddAssignmentScreen({super.key});

  @override
  ConsumerState<AddAssignmentScreen> createState() =>
      _AddAssignmentScreenState();
}

class _AddAssignmentScreenState extends ConsumerState<AddAssignmentScreen> {
  bool _isLoading = false;

  Future<void> _handleSubmit(AssignmentModel assignment) async {
    setState(() => _isLoading = true);

    try {
      final repo = ref.read(assignmentRepositoryProvider);
      await repo.createAssignment(assignment);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Assignment created successfully!'),
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
            content: Text('Failed to create assignment: ${e.toString()}'),
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
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return AppScaffold(
      title: "Add Task",
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : AssignmentForm(
              ownerId: uid,
              onSubmit: _handleSubmit,
              isLoading: _isLoading,
            ),
    );
  }
}
