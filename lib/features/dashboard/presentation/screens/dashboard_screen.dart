import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_section_title.dart';

import '../../../auth/presentation/providers/auth_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      title: "StudySphere",

      actions: [
        IconButton(
          tooltip: "Profile",
          onPressed: () => context.go('/profile'),
          icon: const Icon(Icons.person),
        ),

        IconButton(
          tooltip: "Logout",
          onPressed: () async {
            await ref.read(authRepositoryProvider).signOut();
          },
          icon: const Icon(Icons.logout),
        ),
      ],

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionTitle(title: "Welcome Back 👋"),

          const SizedBox(height: 20),

          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Upcoming Assignments",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 10),

                Text("No assignments available."),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const AppSectionTitle(title: "Quick Actions"),

          const SizedBox(height: 16),

          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _QuickActionCard(
                  icon: Icons.assignment,
                  title: "Assignments",
                  onTap: () => context.go('/assignments'),
                ),

                _QuickActionCard(
                  icon: Icons.people,
                  title: "Community",
                  onTap: () => context.go('/community'),
                ),

                _QuickActionCard(
                  icon: Icons.person,
                  title: "Profile",
                  onTap: () => context.go('/profile'),
                ),

                _QuickActionCard(
                  icon: Icons.event,
                  title: "Events",
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40),

          const SizedBox(height: 12),

          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
