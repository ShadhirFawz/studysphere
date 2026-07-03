import 'package:equatable/equatable.dart';

class AssignmentTag extends Equatable {
  final String name;

  const AssignmentTag({required this.name});

  Map<String, dynamic> toMap() {
    return {'name': name};
  }

  factory AssignmentTag.fromMap(Map<String, dynamic> map) {
    return AssignmentTag(name: map['name'] ?? '');
  }

  @override
  List<Object?> get props => [name];
}
