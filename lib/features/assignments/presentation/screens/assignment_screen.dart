import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_scaffold.dart';

import '../providers/assignment_provider.dart';
import '../widgets/assignment_card.dart';

class AssignmentScreen extends ConsumerWidget {
  const AssignmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentsAsync = ref.watch(assignmentsProvider);

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
            padding: const EdgeInsets.only(left: 2, right: 2),
            itemCount: assignments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 2),
            itemBuilder: (_, index) {
              return AssignmentCard(assignment: assignments[index]);
            },
          );
        },
      ),
    );
  }
}
