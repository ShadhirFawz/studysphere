class UserModel {
  final String uid;
  final String email;
  final String fullName;

  const UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
  });

  Map<String, dynamic> toMap() {
    return {'uid': uid, 'email': email, 'fullName': fullName};
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
    );
  }
}
