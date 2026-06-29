import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/profile/data/models/profile_model.dart';
import '../../features/profile/presentation/providers/profile_provider.dart';

final currentUserProvider = FutureProvider<ProfileModel?>((ref) async {
  final firebaseUser = FirebaseAuth.instance.currentUser;

  if (firebaseUser == null) {
    return null;
  }

  return ref
      .read(profileRepositoryProvider)
      .getCurrentProfile(firebaseUser.uid);
});
