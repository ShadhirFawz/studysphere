import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_scaffold.dart';

import '../providers/assignment_provider.dart';
import '../providers/assignment_filter_provider.dart';
import '../providers/assignment_selection_provider.dart';
import '../widgets/assignment_card.dart';
import '../widgets/assignment_filter_chip.dart';
import '../widgets/assignment_search_delegate.dart';
import '../widgets/assignment_sort_dropdown.dart';
import '../widgets/bulk_action_bar.dart';

class AssignmentScreen extends ConsumerWidget {
  const AssignmentScreen({super.key});

  Future<void> _deleteSelectedAssignments(
    BuildContext context,
    WidgetRef ref,
    Set<String> selectedIds,
  ) async {
    if (selectedIds.isEmpty) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Selected Assignments?'),
        content: Text(
          'Are you sure you want to delete ${selectedIds.length} selected assignment(s)? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    final repo = ref.read(assignmentRepositoryProvider);
    int deletedCount = 0;
    int failedCount = 0;

    for (final id in selectedIds) {
      try {
        await repo.deleteAssignment(id);
        deletedCount++;
      } catch (e) {
        failedCount++;
      }
    }

    // Clear selection after deletion
    ref.read(assignmentSelectionProvider.notifier).state = {};
    ref.read(isSelectionModeProvider.notifier).state = false;

    if (context.mounted) {
      String message;
      if (failedCount == 0) {
        message = 'Successfully deleted $deletedCount assignment(s)';
      } else {
        message = 'Deleted $deletedCount assignment(s), $failedCount failed';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: failedCount == 0 ? Colors.green : Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentsAsync = ref.watch(assignmentsProvider);
    final filterState = ref.watch(assignmentFilterProvider);
    final isSelectionMode = ref.watch(isSelectionModeProvider);
    final selectedIds = ref.watch(assignmentSelectionProvider);

    return AppScaffold(
      centerTitle: true,
      title: isSelectionMode ? "Select Tasks" : "Tasks",
      actions: [
        // Hide search and FAB in selection mode
        if (!isSelectionMode) ...[
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
      ],
      floatingActionButton: isSelectionMode
          ? null
          : FloatingActionButton(
              onPressed: () => context.push('/add-assignment'),
              child: const Icon(Icons.assignment_add),
            ),
      body: Column(
        children: [
          // Bulk Action Bar
          if (isSelectionMode)
            BulkActionBar(
              onDeleteSelected: () =>
                  _deleteSelectedAssignments(context, ref, selectedIds),
              onCancelSelection: () {
                ref.read(assignmentSelectionProvider.notifier).state = {};
                ref.read(isSelectionModeProvider.notifier).state = false;
              },
            ),

          // Filter & Sort Bar
          if (!isSelectionMode &&
              assignmentsAsync.when(
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
