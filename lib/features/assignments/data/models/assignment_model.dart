import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'assignment_checklist_item.dart';
import 'assignment_tag.dart';
import 'assignment_attachment.dart';

enum AssignmentType { homework, lab, quiz, presentation, project, exam, custom }

enum AssignmentPriority { low, medium, high, critical }

enum AssignmentStatus {
  draft,
  pending,
  inProgress,
  submitted,
  completed,
  cancelled,
  overdue,
}

enum AssignmentDifficulty { easy, medium, hard }

class AssignmentModel extends Equatable {
  final String id;
  final String ownerId;

  final String title;
  final String description;
  final String course;

  final AssignmentType type;
  final AssignmentPriority priority;
  final AssignmentStatus status;
  final AssignmentDifficulty difficulty;

  final int progress;
  final double estimatedHours;

  final Timestamp startDate;
  final Timestamp dueDate;

  final List<AssignmentChecklistItem> checklist;
  final List<AssignmentTag> tags;

  final String notes;

  final List<AssignmentAttachment> attachments;

  final Timestamp createdAt;
  final Timestamp updatedAt;

  const AssignmentModel({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.course,
    required this.type,
    required this.priority,
    required this.status,
    required this.difficulty,
    required this.progress,
    required this.estimatedHours,
    required this.startDate,
    required this.dueDate,
    required this.checklist,
    required this.tags,
    required this.notes,
    required this.attachments,
    required this.createdAt,
    required this.updatedAt,
  });

  AssignmentModel copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? description,
    String? course,
    AssignmentType? type,
    AssignmentPriority? priority,
    AssignmentStatus? status,
    AssignmentDifficulty? difficulty,
    int? progress,
    double? estimatedHours,
    Timestamp? startDate,
    Timestamp? dueDate,
    List<AssignmentChecklistItem>? checklist,
    List<AssignmentTag>? tags,
    String? notes,
    List<AssignmentAttachment>? attachments,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return AssignmentModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      course: course ?? this.course,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      difficulty: difficulty ?? this.difficulty,
      progress: progress ?? this.progress,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      checklist: checklist ?? this.checklist,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'course': course,
      'type': type.name,
      'priority': priority.name,
      'status': status.name,
      'difficulty': difficulty.name,
      'progress': progress,
      'estimatedHours': estimatedHours,
      'startDate': startDate,
      'dueDate': dueDate,
      'checklist': checklist.map((e) => e.toMap()).toList(),
      'tags': tags.map((e) => e.toMap()).toList(),
      'notes': notes,
      'attachments': attachments.map((e) => e.toMap()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory AssignmentModel.fromDocument(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;

    return AssignmentModel(
      id: doc.id,
      ownerId: map['ownerId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      course: map['course'] ?? '',
      type: AssignmentType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => AssignmentType.homework,
      ),
      priority: AssignmentPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => AssignmentPriority.medium,
      ),
      status: AssignmentStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => AssignmentStatus.pending,
      ),
      difficulty: AssignmentDifficulty.values.firstWhere(
        (e) => e.name == map['difficulty'],
        orElse: () => AssignmentDifficulty.medium,
      ),
      progress: map['progress'] ?? 0,
      estimatedHours: (map['estimatedHours'] ?? 0).toDouble(),
      startDate: map['startDate'] ?? Timestamp.now(),
      dueDate: map['dueDate'] ?? Timestamp.now(),
      checklist: (map['checklist'] as List? ?? [])
          .map(
            (e) =>
                AssignmentChecklistItem.fromMap(Map<String, dynamic>.from(e)),
          )
          .toList(),
      tags: (map['tags'] as List? ?? [])
          .map((e) => AssignmentTag.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      notes: map['notes'] ?? '',
      attachments:
          (map['attachments'] as List<dynamic>?)
              ?.map(
                (e) =>
                    AssignmentAttachment.fromMap(Map<String, dynamic>.from(e)),
              )
              .toList() ??
          [],
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    ownerId,
    title,
    description,
    course,
    type,
    priority,
    status,
    difficulty,
    progress,
    estimatedHours,
    startDate,
    dueDate,
    checklist,
    tags,
    notes,
    attachments,
    createdAt,
    updatedAt,
  ];
}
