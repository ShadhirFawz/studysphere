import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/assignment_tag.dart';
import 'tag_chip.dart';

class TagInputField extends ConsumerStatefulWidget {
  final List<AssignmentTag> tags;
  final ValueChanged<List<AssignmentTag>> onTagsChanged;

  const TagInputField({
    super.key,
    required this.tags,
    required this.onTagsChanged,
  });

  @override
  ConsumerState<TagInputField> createState() => _TagInputFieldState();
}

class _TagInputFieldState extends ConsumerState<TagInputField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addTag(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return;

    // Check if tag already exists
    if (widget.tags.any((t) => t.name.toLowerCase() == trimmed.toLowerCase())) {
      return;
    }

    final newTag = AssignmentTag(name: trimmed);
    final updatedTags = [...widget.tags, newTag];
    widget.onTagsChanged(updatedTags);
    _controller.clear();
  }

  void _removeTag(AssignmentTag tag) {
    final updatedTags = widget.tags.where((t) => t.name != tag.name).toList();
    widget.onTagsChanged(updatedTags);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Input Field
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            labelText: "Tags",
            hintText: "Type a tag and press enter",
            border: const OutlineInputBorder(),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      _addTag(_controller.text);
                    },
                  )
                : null,
          ),
          onFieldSubmitted: _addTag,
        ),
        const SizedBox(height: 8),

        // Tag Chips
        if (widget.tags.isNotEmpty)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: widget.tags.map((tag) {
              return TagChip(tag: tag, onDelete: () => _removeTag(tag));
            }).toList(),
          ),
      ],
    );
  }
}
