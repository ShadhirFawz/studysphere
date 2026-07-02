import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class AssignmentModel extends Equatable {
  final String id;
  final String userId;

  final String title;
  final String description;
  final String course;

  final String priority;
  final String status;

  final Timestamp dueDate;

  final Timestamp createdAt;
  final Timestamp updatedAt;

  const AssignmentModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.course,
    required this.priority,
    required this.status,
    required this.dueDate,
    required this.createdAt,
    required this.updatedAt,
  });

  AssignmentModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? course,
    String? priority,
    String? status,
    Timestamp? dueDate,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return AssignmentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      course: course ?? this.course,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'course': course,
      'priority': priority,
      'status': status,
      'dueDate': dueDate,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory AssignmentModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return AssignmentModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      course: data['course'] ?? '',
      priority: data['priority'] ?? AssignmentPriority.medium,
      status: data['status'] ?? AssignmentStatus.pending,
      dueDate: data['dueDate'] ?? Timestamp.now(),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
    );
  }

  factory AssignmentModel.fromMap(Map<String, dynamic> map, String documentId) {
    return AssignmentModel(
      id: documentId,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      course: map['course'] ?? '',
      priority: map['priority'] ?? AssignmentPriority.medium,
      status: map['status'] ?? AssignmentStatus.pending,
      dueDate: map['dueDate'] ?? Timestamp.now(),
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    description,
    course,
    priority,
    status,
    dueDate,
    createdAt,
    updatedAt,
  ];
}

class AssignmentPriority {
  static const high = 'High';
  static const medium = 'Medium';
  static const low = 'Low';

  static const values = [high, medium, low];
}

class AssignmentStatus {
  static const pending = 'Pending';
  static const inProgress = 'In Progress';
  static const completed = 'Completed';

  static const values = [pending, inProgress, completed];
}
