import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_scaffold.dart';

import '../../data/models/assignment_model.dart';

import '../providers/assignment_provider.dart';

import '../widgets/assignment_form.dart';

class AddAssignmentScreen extends ConsumerWidget {
  const AddAssignmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return AppScaffold(
      title: "Add Assignment",

      body: AssignmentForm(
        ownerId: uid,

        onSubmit: (AssignmentModel assignment) async {
          await ref
              .read(assignmentRepositoryProvider)
              .createAssignment(assignment);

          if (context.mounted) {
            context.pop();
          }
        },
      ),
    );
  }
}
