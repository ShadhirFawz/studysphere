import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/profile_model.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<ProfileModel?> getCurrentProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) return null;

    return ProfileModel.fromMap(doc.data()!);
  }

  Future<void> updateProfile(ProfileModel profile) async {
    await _firestore
        .collection('users')
        .doc(profile.uid)
        .update(profile.toMap());
  }
}
