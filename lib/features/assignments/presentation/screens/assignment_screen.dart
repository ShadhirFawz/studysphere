import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_scaffold.dart';

import '../providers/assignment_provider.dart';
import '../providers/assignment_filter_provider.dart';
import '../widgets/assignment_card.dart';
import '../widgets/assignment_filter_chip.dart';
import '../widgets/assignment_search_delegate.dart';
import '../widgets/assignment_sort_dropdown.dart';

class AssignmentScreen extends ConsumerWidget {
  const AssignmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentsAsync = ref.watch(assignmentsProvider);
    final filterState = ref.watch(assignmentFilterProvider);

    return AppScaffold(
      centerTitle: true,
      title: "Assignments",
      // Removed filter from actions - only search remains
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            showSearch(
              context: context,
              delegate: AssignmentSearchDelegate(ref),
            );
          },
        ),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-assignment'),
        child: const Icon(Icons.assignment_add),
      ),
      body: Column(
        children: [
          // Filter & Sort Bar (only show when there are assignments)
          if (assignmentsAsync.when(
            data: (assignments) => assignments.isNotEmpty,
            loading: () => false,
            error: (_, __) => false,
          ))
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
              child: Row(
                children: [
                  // Filter Chip (Icon Only)
                  const AssignmentFilterChip(),

                  // Active filters count text
                  if (filterState.hasActiveFilters)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        '${filterState.activeFilterCount} active',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),

                  const Spacer(),

                  // Sort Dropdown
                  const AssignmentSortDropdown(),
                ],
              ),
            ),

          // Assignment List
          Expanded(
            child: assignmentsAsync.when(
              loading: () => const AppLoading(),
              error: (e, _) => AppErrorState(message: e.toString()),
              data: (assignments) {
                // Apply filters and sorting to the data
                final filtered = filterState.apply(assignments);

                if (filtered.isEmpty) {
                  if (filterState.hasActiveFilters) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.filter_alt_off,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No matching assignments',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your filters',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              ref
                                      .read(assignmentFilterProvider.notifier)
                                      .state =
                                  const AssignmentFilterState();
                            },
                            child: const Text('Clear Filters'),
                          ),
                        ],
                      ),
                    );
                  }

                  return const AppEmptyState(
                    icon: Icons.assignment_outlined,
                    title: "No Assignments",
                    subtitle: "Tap + to add your first assignment",
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(
                    left: 2,
                    right: 2,
                    top: 8,
                    bottom: 16,
                  ),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 2),
                  itemBuilder: (_, index) {
                    return AssignmentCard(assignment: filtered[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
