import 'package:flutter/material.dart';

class AddChecklistItemField extends StatefulWidget {
  final Function(String) onAdd;

  const AddChecklistItemField({super.key, required this.onAdd});

  @override
  State<AddChecklistItemField> createState() => _AddChecklistItemFieldState();
}

class _AddChecklistItemFieldState extends State<AddChecklistItemField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addItem() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onAdd(text);
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            decoration: const InputDecoration(
              hintText: 'Add checklist item...',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              isDense: true,
            ),
            onSubmitted: (_) => _addItem(),
            textInputAction: TextInputAction.done,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.add_circle, color: Colors.blue),
          onPressed: _addItem,
          tooltip: 'Add item',
        ),
      ],
    );
  }
}
