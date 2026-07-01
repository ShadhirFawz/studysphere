import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_scaffold.dart';

import '../../../../shared/providers/current_user_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentUserProvider);

    return profile.when(
      loading: () => const AppScaffold(title: "Profile", body: AppLoading()),

      error: (error, stack) => AppScaffold(
        title: "Profile",
        body: AppErrorState(message: error.toString()),
      ),

      data: (user) {
        if (user == null) {
          return const AppScaffold(
            title: "Profile",
            body: Center(child: Text("Profile not found")),
          );
        }

        return AppScaffold(
          title: "Profile",

          actions: [
            IconButton(
              onPressed: () {
                context.push('/edit-profile');
              },
              icon: const Icon(Icons.edit),
            ),
          ],

          body: ListView(
            children: [
              Center(
                child: CircleAvatar(
                  radius: 45,
                  child: Text(
                    user.fullName.isNotEmpty
                        ? user.fullName[0].toUpperCase()
                        : "?",
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: Text(
                  user.fullName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Center(child: Text(user.email)),

              const SizedBox(height: 24),

              ListTile(
                leading: const Icon(Icons.school),
                title: const Text("Major"),
                subtitle: Text(
                  user.major.isEmpty ? "Not added yet" : user.major,
                ),
              ),

              ListTile(
                leading: const Icon(Icons.menu_book),
                title: const Text("Courses"),
                subtitle: Text(
                  user.courses.isEmpty
                      ? "No courses added"
                      : user.courses.join(", "),
                ),
              ),

              ListTile(
                leading: const Icon(Icons.schedule),
                title: const Text("Study Habit"),
                subtitle: Text(
                  user.studyHabit.isEmpty ? "Not added yet" : user.studyHabit,
                ),
              ),

              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text("Bio"),
                subtitle: Text(user.bio.isEmpty ? "No bio yet" : user.bio),
              ),
            ],
          ),
        );
      },
    );
  }
}
