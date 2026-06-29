import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/providers/current_user_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentUserProvider);

    return profile.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(body: Center(child: Text('Profile not found')));
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            actions: [
              IconButton(
                onPressed: () {
                  context.push('/edit-profile');
                },
                icon: const Icon(Icons.edit),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 45,
                  child: Text(
                    user.fullName.isNotEmpty
                        ? user.fullName[0].toUpperCase()
                        : "?",
                    style: const TextStyle(fontSize: 28),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  user.fullName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(user.email),

                const SizedBox(height: 30),

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
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) =>
          Scaffold(body: Center(child: Text(error.toString()))),
    );
  }
}
