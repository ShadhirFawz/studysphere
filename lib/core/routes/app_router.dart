import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:studysphere/features/assignments/data/models/assignment_model.dart';
import 'package:studysphere/features/assignments/presentation/screens/add_assignment_screen.dart';
import 'package:studysphere/features/assignments/presentation/screens/edit_assignment_screen.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';

import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';

import '../../features/assignments/presentation/screens/assignment_screen.dart';
import '../../features/community/presentation/screens/community_screen.dart';

import '../../features/navigation/presentation/screens/navigation_shell.dart';

import 'router_refresh_stream.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',

    refreshListenable: RouterRefreshStream(
      FirebaseAuth.instance.authStateChanges(),
    ),
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;

      final loggingIn =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (user == null) {
        return loggingIn ? null : '/login';
      }

      if (loggingIn) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return NavigationShell(navigationShell: navigationShell);
        },
        branches: [
          // HOME (Dashboard)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),

          // ASSIGNMENTS
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/assignments',
                builder: (context, state) => const AssignmentScreen(),
              ),
              GoRoute(
                path: '/add-assignment',
                builder: (context, state) => const AddAssignmentScreen(),
              ),
              GoRoute(
                path: '/edit-assignment',
                builder: (context, state) {
                  final assignment = state.extra as AssignmentModel;
                  return EditAssignmentScreen(assignment: assignment);
                },
              ),
            ],
          ),

          // COMMUNITY
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/community',
                builder: (context, state) => const CommunityScreen(),
              ),
            ],
          ),

          // PROFILE
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
