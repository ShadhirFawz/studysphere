import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/assignment_filter_provider.dart';
import 'assignment_filter_sheet.dart';

class AssignmentFilterChip extends ConsumerWidget {
  final VoidCallback? onTap;

  const AssignmentFilterChip({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(assignmentFilterProvider);
    final count = filter.activeFilterCount;

    if (count == 0) {
      return IconButton(
        icon: const Icon(Icons.filter_list),
        onPressed: () => _showFilterSheet(context, ref),
        tooltip: 'Filter',
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () => _showFilterSheet(context, ref),
          tooltip: 'Filter',
        ),
        Positioned(
          top: 4,
          right: 4,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  void _showFilterSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const AssignmentFilterSheet(),
    );
  }
}
