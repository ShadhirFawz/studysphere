import 'package:flutter/material.dart';

import '../../data/models/assignment_checklist_item.dart';
import 'checklist_tile.dart';
import 'add_checklist_item_field.dart';

class ChecklistSection extends StatefulWidget {
  final List<AssignmentChecklistItem> items;
  final Function(List<AssignmentChecklistItem>) onChanged;

  const ChecklistSection({
    super.key,
    required this.items,
    required this.onChanged,
  });

  @override
  State<ChecklistSection> createState() => _ChecklistSectionState();
}

class _ChecklistSectionState extends State<ChecklistSection> {
  void _addItem(String title) {
    final newItem = AssignmentChecklistItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      completed: false,
    );
    final updatedItems = [...widget.items, newItem];
    widget.onChanged(updatedItems);
  }

  void _toggleItem(AssignmentChecklistItem item) {
    final updatedItems = widget.items.map((e) {
      if (e.id == item.id) {
        return e.copyWith(completed: !e.completed);
      }
      return e;
    }).toList();
    widget.onChanged(updatedItems);
  }

  void _deleteItem(AssignmentChecklistItem item) {
    final updatedItems = widget.items.where((e) => e.id != item.id).toList();
    widget.onChanged(updatedItems);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            const Text(
              'Checklist',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${widget.items.length}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Items List
        if (widget.items.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: widget.items.map((item) {
                return ChecklistTile(
                  item: item,
                  onToggle: () => _toggleItem(item),
                  onDelete: () => _deleteItem(item),
                );
              }).toList(),
            ),
          ),

        const SizedBox(height: 8),

        // Add Item Field
        AddChecklistItemField(onAdd: _addItem),
      ],
    );
  }
}
