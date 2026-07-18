import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/assignment_filter_provider.dart';

class AssignmentSortDropdown extends ConsumerWidget {
  const AssignmentSortDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(assignmentFilterProvider);

    final sortOptions = <String?>[
      null,
      'title',
      'dueDate',
      'priority',
      'progress',
      'estimatedHours',
      'status',
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: filter.sortBy,
              hint: Text(
                'Default',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              isDense: true,
              iconSize: 16,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
              dropdownColor: Colors.white,
              items: sortOptions.map((option) {
                final displayName = option == null
                    ? 'Default'
                    : option[0].toUpperCase() + option.substring(1);

                return DropdownMenuItem<String?>(
                  value: option,
                  child: Text(
                    displayName,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade800,
                      fontWeight: option == null
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) {
                  ref.read(assignmentFilterProvider.notifier).state = filter
                      .copyWith(sortBy: null, sortAscending: true);
                } else {
                  ref.read(assignmentFilterProvider.notifier).state = filter
                      .copyWith(sortBy: value);
                }
              },
              icon: Icon(
                Icons.arrow_drop_down,
                size: 16,
                color: Colors.grey.shade600,
              ),
              elevation: 0,
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            filter.sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
            size: 18,
            color: filter.sortBy == null ? Colors.grey.shade400 : Colors.blue,
          ),
          onPressed: filter.sortBy == null
              ? null
              : () {
                  ref.read(assignmentFilterProvider.notifier).state = filter
                      .copyWith(sortAscending: !filter.sortAscending);
                },
          tooltip: filter.sortAscending ? 'Ascending' : 'Descending',
        ),
      ],
    );
  }
}
