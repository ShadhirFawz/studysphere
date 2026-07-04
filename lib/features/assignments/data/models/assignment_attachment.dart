import 'package:cloud_firestore/cloud_firestore.dart';

class AssignmentAttachment {
  final String id;

  final String fileName;
  final String fileUrl;
  final String fileType;
  final int fileSize;

  final String uploadedBy;

  final Timestamp uploadedAt;

  const AssignmentAttachment({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    required this.fileSize,
    required this.uploadedBy,
    required this.uploadedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileType': fileType,
      'fileSize': fileSize,
      'uploadedBy': uploadedBy,
      'uploadedAt': uploadedAt,
    };
  }

  factory AssignmentAttachment.fromMap(Map<String, dynamic> map) {
    return AssignmentAttachment(
      id: map['id'] ?? '',
      fileName: map['fileName'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      fileType: map['fileType'] ?? '',
      fileSize: map['fileSize'] ?? 0,
      uploadedBy: map['uploadedBy'] ?? '',
      uploadedAt: map['uploadedAt'] ?? Timestamp.now(),
    );
  }
}
