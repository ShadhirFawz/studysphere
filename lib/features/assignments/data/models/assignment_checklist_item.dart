import 'package:equatable/equatable.dart';

class AssignmentChecklistItem extends Equatable {
  final String id;
  final String title;
  final bool completed;

  const AssignmentChecklistItem({
    required this.id,
    required this.title,
    required this.completed,
  });

  AssignmentChecklistItem copyWith({
    String? id,
    String? title,
    bool? completed,
  }) {
    return AssignmentChecklistItem(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'completed': completed};
  }

  factory AssignmentChecklistItem.fromMap(Map<String, dynamic> map) {
    return AssignmentChecklistItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      completed: map['completed'] ?? false,
    );
  }

  @override
  List<Object?> get props => [id, title, completed];
}
