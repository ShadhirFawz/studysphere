import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/datasources/assignment_datasource.dart';
import '../../data/repositories/assignment_repository.dart';
import '../../data/models/assignment_model.dart';

final assignmentDatasourceProvider = Provider<AssignmentDatasource>((ref) {
  return AssignmentDatasource();
});

final assignmentRepositoryProvider = Provider<AssignmentRepository>((ref) {
  return AssignmentRepository(ref.read(assignmentDatasourceProvider));
});

final currentUserIdProvider = Provider<String?>((ref) {
  return FirebaseAuth.instance.currentUser?.uid;
});

final assignmentsStreamProvider = StreamProvider<List<AssignmentModel>>((ref) {
  final repo = ref.read(assignmentRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) {
    return const Stream.empty();
  }

  return repo.getUserAssignments(userId);
});
