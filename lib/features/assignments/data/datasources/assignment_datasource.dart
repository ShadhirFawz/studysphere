import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/assignment_model.dart';

class AssignmentDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _collection => _firestore.collection('assignments');

  Future<void> createAssignment(AssignmentModel assignment) async {
    await _collection.add(assignment.toMap());
  }

  Future<void> updateAssignment(AssignmentModel assignment) async {
    await _collection.doc(assignment.id).update(assignment.toMap());
  }

  Future<void> deleteAssignment(String id) async {
    await _collection.doc(id).delete();
  }

  Stream<List<AssignmentModel>> getUserAssignments(String userId) {
    return _collection
        .where('userId', isEqualTo: userId)
        .orderBy('dueDate')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) => AssignmentModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList();
        });
  }

  Future<AssignmentModel?> getAssignmentById(String id) async {
    final doc = await _collection.doc(id).get();

    if (!doc.exists) return null;

    return AssignmentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }
}
