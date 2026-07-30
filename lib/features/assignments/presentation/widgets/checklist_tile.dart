import 'package:flutter/material.dart';

import '../../data/models/assignment_checklist_item.dart';

class ChecklistTile extends StatelessWidget {
  final AssignmentChecklistItem item;
  final VoidCallback? onToggle;
  final VoidCallback? onDelete;
  final ValueChanged<String>? onRename;

  const ChecklistTile({
    super.key,
    required this.item,
    this.onToggle,
    this.onDelete,
    this.onRename,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      leading: GestureDetector(
        onTap: onToggle,
        child: Icon(
          item.completed ? Icons.check_circle : Icons.radio_button_unchecked,
          color: item.completed ? Colors.green : Colors.grey.shade400,
          size: 22,
        ),
      ),
      title: Text(
        item.title,
        style: TextStyle(
          decoration: item.completed ? TextDecoration.lineThrough : null,
          color: item.completed ? Colors.grey.shade600 : Colors.black87,
          fontSize: 14,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.close, size: 18, color: Colors.grey),
        onPressed: onDelete,
        tooltip: 'Remove item',
      ),
    );
  }
}
