import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/assignment_attachment.dart';

class AssignmentAttachmentCard extends StatelessWidget {
  final AssignmentAttachment attachment;
  final VoidCallback? onDelete;

  const AssignmentAttachmentCard({
    super.key,
    required this.attachment,
    this.onDelete,
  });

  IconData _icon() {
    final ext = attachment.fileType.toLowerCase();

    if (["jpg", "jpeg", "png", "gif", "webp"].contains(ext)) {
      return Icons.image;
    }

    if (ext == "pdf") {
      return Icons.picture_as_pdf;
    }

    if (["doc", "docx"].contains(ext)) {
      return Icons.description;
    }

    if (["ppt", "pptx"].contains(ext)) {
      return Icons.slideshow;
    }

    if (["xls", "xlsx"].contains(ext)) {
      return Icons.table_chart;
    }

    return Icons.attach_file;
  }

  Future<void> _open() async {
    final uri = Uri.parse(attachment.fileUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _share() async {
    await Share.share(attachment.fileUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(_icon()),
        title: Text(
          attachment.fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(attachment.fileType),
        onTap: _open,
        trailing: PopupMenuButton(
          itemBuilder: (_) => [
            const PopupMenuItem(value: "open", child: Text("Open")),
            const PopupMenuItem(value: "share", child: Text("Share")),
            if (onDelete != null)
              const PopupMenuItem(value: "delete", child: Text("Delete")),
          ],
          onSelected: (value) {
            switch (value) {
              case "open":
                _open();
                break;

              case "share":
                _share();
                break;

              case "delete":
                onDelete?.call();
                break;
            }
          },
        ),
      ),
    );
  }
}
