import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/assignment_model.dart';
import '../providers/assignment_filter_provider.dart';
import '../providers/assignment_provider.dart';

class AssignmentFilterSheet extends ConsumerStatefulWidget {
  const AssignmentFilterSheet({super.key});

  @override
  ConsumerState<AssignmentFilterSheet> createState() =>
      _AssignmentFilterSheetState();
}

class _AssignmentFilterSheetState extends ConsumerState<AssignmentFilterSheet> {
  late AssignmentFilterState filter;
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    filter = ref.read(assignmentFilterProvider);
  }

  @override
  Widget build(BuildContext context) {
    final allAssignments = ref.watch(assignmentsProvider).valueOrNull ?? [];
    final availableCourses =
        allAssignments
            .map((a) => a.course)
            .toSet()
            .where((c) => c.isNotEmpty)
            .toList()
          ..sort();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (filter.hasActiveFilters)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        filter = const AssignmentFilterState();
                        ref.read(assignmentFilterProvider.notifier).state =
                            filter;
                      });
                    },
                    child: const Text('Clear All'),
                  ),
              ],
            ),
          ),
          const Divider(),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Priority Filter
                        _buildFilterSection(
                          title: 'Priority',
                          options: AssignmentPriority.values,
                          selectedOptions: filter.priorities,
                          getLabel: (p) => p.name,
                          onChanged: (selected) {
                            setState(() {
                              filter = filter.copyWith(priorities: selected);
                              ref
                                      .read(assignmentFilterProvider.notifier)
                                      .state =
                                  filter;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Status Filter
                        _buildFilterSection(
                          title: 'Status',
                          options: AssignmentStatus.values,
                          selectedOptions: filter.statuses,
                          getLabel: (s) => s.name,
                          onChanged: (selected) {
                            setState(() {
                              filter = filter.copyWith(statuses: selected);
                              ref
                                      .read(assignmentFilterProvider.notifier)
                                      .state =
                                  filter;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Difficulty Filter
                        _buildFilterSection(
                          title: 'Difficulty',
                          options: AssignmentDifficulty.values,
                          selectedOptions: filter.difficulties,
                          getLabel: (d) => d.name,
                          onChanged: (selected) {
                            setState(() {
                              filter = filter.copyWith(difficulties: selected);
                              ref
                                      .read(assignmentFilterProvider.notifier)
                                      .state =
                                  filter;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Type Filter
                        _buildFilterSection(
                          title: 'Type',
                          options: AssignmentType.values,
                          selectedOptions: filter.types,
                          getLabel: (t) => t.name,
                          onChanged: (selected) {
                            setState(() {
                              filter = filter.copyWith(types: selected);
                              ref
                                      .read(assignmentFilterProvider.notifier)
                                      .state =
                                  filter;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Course Filter (if available)
                        if (availableCourses.isNotEmpty)
                          _buildFilterSection(
                            title: 'Course',
                            options: availableCourses,
                            selectedOptions: filter.courses,
                            getLabel: (c) => c,
                            onChanged: (selected) {
                              setState(() {
                                filter = filter.copyWith(courses: selected);
                                ref
                                        .read(assignmentFilterProvider.notifier)
                                        .state =
                                    filter;
                              });
                            },
                          ),
                        const SizedBox(height: 16),

                        // Sort Options
                        _buildSortSection(),
                      ],
                    ),
                  ),
          ),

          // Bottom Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Reset filter to default
                      setState(() {
                        filter = const AssignmentFilterState();
                        ref.read(assignmentFilterProvider.notifier).state =
                            filter;
                      });
                    },
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Apply Filters',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection<T>({
    required String title,
    required List<T> options,
    required List<T> selectedOptions,
    required String Function(T) getLabel,
    required Function(List<T>) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: options.map((option) {
            final isSelected = selectedOptions.contains(option);
            return FilterChip(
              label: Text(
                getLabel(option)[0].toUpperCase() +
                    getLabel(option).substring(1),
              ),
              selected: isSelected,
              onSelected: (_) {
                final newSelected = isSelected
                    ? selectedOptions.where((e) => e != option).toList()
                    : [...selectedOptions, option];
                onChanged(newSelected);
              },
              selectedColor: Colors.blue.shade100,
              checkmarkColor: Colors.blue,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSortSection() {
    final sortOptions = <String?>[
      null,
      'title',
      'dueDate',
      'priority',
      'progress',
      'estimatedHours',
      'status',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sort By',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String?>(
                value: filter.sortBy,
                hint: const Text('Default'),
                items: sortOptions.map((option) {
                  return DropdownMenuItem<String?>(
                    value: option,
                    child: Text(
                      option == null
                          ? 'Default'
                          : option[0].toUpperCase() + option.substring(1),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    if (value == null) {
                      filter = filter.copyWith(
                        sortBy: null,
                        sortAscending: true,
                      );
                    } else {
                      filter = filter.copyWith(sortBy: value);
                    }
                    ref.read(assignmentFilterProvider.notifier).state = filter;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                filter.sortAscending
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                color: filter.sortBy == null ? Colors.grey : Colors.blue,
              ),
              onPressed: filter.sortBy == null
                  ? null
                  : () {
                      setState(() {
                        filter = filter.copyWith(
                          sortAscending: !filter.sortAscending,
                        );
                        ref.read(assignmentFilterProvider.notifier).state =
                            filter;
                      });
                    },
              tooltip: filter.sortAscending ? 'Ascending' : 'Descending',
            ),
          ],
        ),
      ],
    );
  }
}
