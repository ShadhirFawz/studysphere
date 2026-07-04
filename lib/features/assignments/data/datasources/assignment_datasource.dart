import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/assignment_model.dart';

class AssignmentDatasource {
  AssignmentDatasource();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('assignments');

  /// CREATE
  Future<String> createAssignment(AssignmentModel assignment) async {
    final doc = await _collection.add(assignment.toMap());
    return doc.id;
  }

  /// UPDATE
  Future<void> updateAssignment(AssignmentModel assignment) async {
    await _collection
        .doc(assignment.id)
        .update(assignment.copyWith(updatedAt: Timestamp.now()).toMap());
  }

  /// DELETE
  Future<void> deleteAssignment(String assignmentId) async {
    await _collection.doc(assignmentId).delete();
  }

  /// SINGLE DOCUMENT
  Future<AssignmentModel?> getAssignmentById(String assignmentId) async {
    final snapshot = await _collection.doc(assignmentId).get();

    if (!snapshot.exists) return null;

    return AssignmentModel.fromDocument(snapshot);
  }

  /// USER ASSIGNMENTS
  Stream<List<AssignmentModel>> getUserAssignments(String ownerId) {
    return _collection
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('dueDate')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AssignmentModel.fromDocument(doc))
              .toList(),
        );
  }

  /// UPCOMING
  Stream<List<AssignmentModel>> getUpcomingAssignments(String ownerId) {
    return _collection
        .where('ownerId', isEqualTo: ownerId)
        .where('status', isNotEqualTo: AssignmentStatus.completed.name)
        .orderBy('status')
        .orderBy('dueDate')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AssignmentModel.fromDocument(doc))
              .toList(),
        );
  }
}
