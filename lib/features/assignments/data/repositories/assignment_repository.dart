import '../datasources/assignment_datasource.dart';
import '../models/assignment_model.dart';

class AssignmentRepository {
  final AssignmentDatasource _datasource;

  AssignmentRepository(this._datasource);

  Future<String> createAssignment(AssignmentModel assignment) {
    return _datasource.createAssignment(assignment);
  }

  Future<void> updateAssignment(AssignmentModel assignment) {
    return _datasource.updateAssignment(assignment);
  }

  Future<void> deleteAssignment(String assignmentId) {
    return _datasource.deleteAssignment(assignmentId);
  }

  Future<AssignmentModel?> getAssignmentById(String assignmentId) {
    return _datasource.getAssignmentById(assignmentId);
  }

  Stream<List<AssignmentModel>> getUserAssignments(String ownerId) {
    return _datasource.getUserAssignments(ownerId);
  }

  Stream<List<AssignmentModel>> getUpcomingAssignments(String ownerId) {
    return _datasource.getUpcomingAssignments(ownerId);
  }
}
