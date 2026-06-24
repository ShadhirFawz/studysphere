String firebaseAuthErrorMessage(String code) {
  switch (code) {
    case 'email-already-in-use':
      return 'Email already exists';

    case 'weak-password':
      return 'Password is too weak';

    case 'invalid-email':
      return 'Invalid email address';

    default:
      return 'Something went wrong';
  }
}
