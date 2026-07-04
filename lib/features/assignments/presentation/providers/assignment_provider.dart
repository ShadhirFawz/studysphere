import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/assignment_datasource.dart';
import '../../data/models/assignment_model.dart';
import '../../data/repositories/assignment_repository.dart';

final assignmentDatasourceProvider = Provider<AssignmentDatasource>((ref) {
  return AssignmentDatasource();
});

final assignmentRepositoryProvider = Provider<AssignmentRepository>((ref) {
  return AssignmentRepository(ref.read(assignmentDatasourceProvider));
});

final currentAssignmentUserProvider = Provider<String?>((ref) {
  return FirebaseAuth.instance.currentUser?.uid;
});

final assignmentsProvider = StreamProvider<List<AssignmentModel>>((ref) {
  final uid = ref.watch(currentAssignmentUserProvider);

  if (uid == null) {
    return const Stream.empty();
  }

  return ref.read(assignmentRepositoryProvider).getUserAssignments(uid);
});

final upcomingAssignmentsProvider = StreamProvider<List<AssignmentModel>>((
  ref,
) {
  final uid = ref.watch(currentAssignmentUserProvider);

  if (uid == null) {
    return const Stream.empty();
  }

  return ref.read(assignmentRepositoryProvider).getUpcomingAssignments(uid);
});
