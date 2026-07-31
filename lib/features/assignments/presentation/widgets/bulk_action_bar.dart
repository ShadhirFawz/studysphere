import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/assignment_selection_provider.dart';

class BulkActionBar extends ConsumerWidget {
  final VoidCallback onDeleteSelected;
  final VoidCallback onCancelSelection;

  const BulkActionBar({
    super.key,
    required this.onDeleteSelected,
    required this.onCancelSelection,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIds = ref.watch(assignmentSelectionProvider);
    final count = selectedIds.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.blue.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Selection count
          Expanded(
            child: Text(
              '$count selected',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade700,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Cancel button
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onCancelSelection,
            tooltip: 'Cancel selection',
            color: Colors.grey.shade600,
          ),

          // Delete button
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: count > 0 ? onDeleteSelected : null,
            tooltip: 'Delete selected',
            color: count > 0 ? Colors.red : Colors.grey.shade400,
          ),
        ],
      ),
    );
  }
}
