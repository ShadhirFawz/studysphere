import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_scaffold.dart';

import '../providers/assignment_provider.dart';
import '../widgets/assignment_card.dart';

class AssignmentScreen extends ConsumerWidget {
  const AssignmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentsAsync = ref.watch(assignmentsStreamProvider);

    return AppScaffold(
      title: "Assignments",

      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-assignment'),
        child: const Icon(Icons.assignment_add),
      ),

      body: assignmentsAsync.when(
        loading: () => const AppLoading(),

        error: (e, _) => AppErrorState(message: e.toString()),

        data: (assignments) {
          if (assignments.isEmpty) {
            return const AppEmptyState(
              icon: Icons.assignment_outlined,
              title: "No Assignments",
              subtitle: "Tap + to add your first assignment",
            );
          }

          return ListView.separated(
            itemCount: assignments.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final assignment = assignments[index];

              return AssignmentCard(assignment: assignment);
            },
          );
        },
      ),
    );
  }
}
