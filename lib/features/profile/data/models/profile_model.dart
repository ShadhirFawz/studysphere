class ProfileModel {
  final String uid;
  final String fullName;
  final String email;

  final String profileImage;
  final String major;
  final String bio;

  final List<String> courses;

  final String studyHabit;

  final String role;

  final DateTime createdAt;
  final DateTime updatedAt;

  const ProfileModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.profileImage,
    required this.major,
    required this.bio,
    required this.courses,
    required this.studyHabit,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'profileImage': profileImage,
      'major': major,
      'bio': bio,
      'courses': courses,
      'studyHabit': studyHabit,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      profileImage: map['profileImage'] ?? '',
      major: map['major'] ?? '',
      bio: map['bio'] ?? '',
      courses: List<String>.from(map['courses'] ?? []),
      studyHabit: map['studyHabit'] ?? '',
      role: map['role'] ?? 'student',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
    );
  }
}
