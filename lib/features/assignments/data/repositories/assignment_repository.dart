import '../datasources/assignment_datasource.dart';
import '../models/assignment_model.dart';

class AssignmentRepository {
  final AssignmentDatasource _datasource;

  AssignmentRepository(this._datasource);

  Future<void> createAssignment(AssignmentModel assignment) {
    return _datasource.createAssignment(assignment);
  }

  Future<void> updateAssignment(AssignmentModel assignment) {
    return _datasource.updateAssignment(assignment);
  }

  Future<void> deleteAssignment(String id) {
    return _datasource.deleteAssignment(id);
  }

  Stream<List<AssignmentModel>> getUserAssignments(String userId) {
    return _datasource.getUserAssignments(userId);
  }

  Future<AssignmentModel?> getAssignmentById(String id) {
    return _datasource.getAssignmentById(id);
  }
}
