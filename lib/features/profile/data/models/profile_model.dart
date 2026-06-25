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
    );
  }
}
