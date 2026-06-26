import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          // Profile Avatar Button
          IconButton(
            icon: const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, size: 18, color: Colors.white),
            ),
            onPressed: () {
              context.push('/profile');
            },
            tooltip: 'Profile',
          ),
          const SizedBox(width: 4),
          // Logout Button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Dashboard Screen',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await ref.read(authServiceProvider).signOut();
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        },
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
      ),
    );
  }
}
