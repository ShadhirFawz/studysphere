import 'package:flutter/material.dart';

class AppErrorState extends StatelessWidget {
  final String message;

  final VoidCallback? onRetry;

  const AppErrorState({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 70, color: Colors.red),

          const SizedBox(height: 20),

          Text(message, textAlign: TextAlign.center),

          const SizedBox(height: 20),

          if (onRetry != null)
            ElevatedButton(onPressed: onRetry, child: const Text("Retry")),
        ],
      ),
    );
  }
}
