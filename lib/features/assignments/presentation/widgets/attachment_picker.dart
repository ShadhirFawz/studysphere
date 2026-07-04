import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class AttachmentPicker extends StatefulWidget {
  final ValueChanged<List<File>> onChanged;

  const AttachmentPicker({super.key, required this.onChanged});

  @override
  State<AttachmentPicker> createState() => _AttachmentPickerState();
}

class _AttachmentPickerState extends State<AttachmentPicker> {
  List<File> files = [];

  Future<void> pickFiles() async {
    final result = await FilePicker.pickFiles(allowMultiple: true);

    if (result == null) return;

    files = result.paths.whereType<String>().map(File.new).toList();

    widget.onChanged(files);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: pickFiles,
          icon: const Icon(Icons.attach_file),
          label: const Text("Attach Files"),
        ),
        const SizedBox(height: 10),
        ...files.map(
          (e) => ListTile(
            dense: true,
            leading: const Icon(Icons.insert_drive_file),
            title: Text(
              e.path.split('/').last,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
