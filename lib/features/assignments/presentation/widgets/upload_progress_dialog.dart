import 'package:flutter/material.dart';

class UploadProgressDialog {
  static Future<void> show(
    BuildContext context, {
    required int totalFiles,
    required Function() onCancel,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _UploadProgressDialogContent(
        totalFiles: totalFiles,
        onCancel: onCancel,
      ),
    );
  }

  static void update(
    BuildContext context,
    int completed,
    int total,
    double progress,
  ) {
    final state = context.findAncestorStateOfType<_UploadProgressDialogState>();
    state?.updateProgress(completed, total, progress);
  }

  static void complete(BuildContext context) {
    final state = context.findAncestorStateOfType<_UploadProgressDialogState>();
    state?.complete();
  }

  static void close(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}

class _UploadProgressDialogContent extends StatefulWidget {
  final int totalFiles;
  final VoidCallback onCancel;

  const _UploadProgressDialogContent({
    required this.totalFiles,
    required this.onCancel,
  });

  @override
  State<_UploadProgressDialogContent> createState() =>
      _UploadProgressDialogState();
}

class _UploadProgressDialogState extends State<_UploadProgressDialogContent> {
  int _completed = 0;
  int _total = 0;
  double _progress = 0;
  bool _isComplete = false;

  void updateProgress(int completed, int total, double progress) {
    setState(() {
      _completed = completed;
      _total = total;
      _progress = progress;
    });
  }

  void complete() {
    setState(() {
      _isComplete = true;
      _progress = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDone = _isComplete || (_total > 0 && _completed >= _total);

    return AlertDialog(
      title: const Text('Uploading Files'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated Icon
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDone ? Colors.green.shade50 : Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isDone
                  ? const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 40,
                    )
                  : const Icon(
                      Icons.cloud_upload,
                      color: Colors.blue,
                      size: 40,
                    ),
            ),
          ),
          const SizedBox(height: 16),

          // Progress Info
          if (_total > 0) ...[
            Text(
              '$_completed of $_total files uploaded',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ] else ...[
            const Text(
              'Preparing files...',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
          const SizedBox(height: 12),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              color: isDone ? Colors.green : Colors.blue,
            ),
          ),
          const SizedBox(height: 8),

          // Percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${(_progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDone ? Colors.green : Colors.blue,
                ),
              ),
            ],
          ),

          if (!isDone && _progress > 0 && _progress < 1)
            const SizedBox(height: 8),

          if (!isDone && _progress > 0 && _progress < 1)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                Row(
                  children: [
                    Icon(
                      Icons.insert_drive_file,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'File ${_completed + 1} uploading...',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
      actions: [
        if (!isDone)
          TextButton(onPressed: widget.onCancel, child: const Text('Cancel')),
        if (isDone)
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
      ],
    );
  }
}
