import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';

class AttachmentPicker extends StatefulWidget {
  final ValueChanged<List<File>> onChanged;

  const AttachmentPicker({super.key, required this.onChanged});

  @override
  State<AttachmentPicker> createState() => _AttachmentPickerState();
}

class _AttachmentPickerState extends State<AttachmentPicker> {
  List<File> files = [];

  Future<void> pickFiles() async {
    try {
      final typeGroup = XTypeGroup(
        label: 'All Files',
        extensions: [
          'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', // Images
          'mp4', 'mov', 'avi', 'mkv', 'wmv', 'flv', // Videos
          'pdf',
          'doc',
          'docx',
          'txt',
          'xls',
          'xlsx',
          'ppt',
          'pptx', // Documents
          'zip', 'rar', '7z', // Archives
        ],
        mimeTypes: [
          'image/*',
          'video/*',
          'application/pdf',
          'application/msword',
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
          'text/plain',
        ],
      );

      final List<XFile> result = await openFiles(
        acceptedTypeGroups: [typeGroup],
      );

      if (result.isEmpty) return;

      final newFiles = result.map((xFile) => File(xFile.path)).toList();

      setState(() {
        files = newFiles;
        widget.onChanged(files);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking files: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
        if (files.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'No files attached',
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          ...files.map(
            (e) => ListTile(
              dense: true,
              leading: const Icon(Icons.insert_drive_file),
              title: Text(
                e.path.split('/').last,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () {
                  setState(() {
                    files.remove(e);
                    widget.onChanged(files);
                  });
                },
                tooltip: 'Remove file',
              ),
            ),
          ),
      ],
    );
  }
}
