String firebaseAuthErrorMessage(String code) {
  switch (code) {
    case 'email-already-in-use':
      return 'This email is already registered. Please use a different email or login.';

    case 'weak-password':
      return 'Password is too weak. Please use at least 6 characters.';

    case 'invalid-email':
      return 'Invalid email address. Please enter a valid email.';

    case 'user-not-found':
      return 'No account found with this email. Please register first.';

    case 'wrong-password':
      return 'Incorrect password. Please try again.';

    case 'too-many-requests':
      return 'Too many failed attempts. Please try again later.';

    case 'network-request-failed':
      return 'Network error. Please check your internet connection.';

    case 'user-disabled':
      return 'This account has been disabled. Please contact support.';

    case 'operation-not-allowed':
      return 'Email/password sign-in is not enabled. Please contact support.';

    case 'requires-recent-login':
      return 'This operation requires recent authentication. Please login again.';

    case 'account-exists-with-different-credential':
      return 'An account already exists with the same email but different sign-in credentials.';

    case 'credential-already-in-use':
      return 'This credential is already associated with a different account.';

    case 'invalid-credential':
      return 'Invalid credentials. Please check your email and password.';

    default:
      return 'Something went wrong. Please try again.';
  }
}
