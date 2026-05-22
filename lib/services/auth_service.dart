import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthService {
  static const Duration _requestTimeout = Duration(seconds: 8);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  Future<User?> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    ).timeout(_requestTimeout);
    return credential.user;
  }

  Future<User?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    ).timeout(_requestTimeout);

    final user = credential.user;
    if (user == null) {
      return null;
    }

    await user.updateDisplayName(name);
    await _database.ref('users/${user.uid}/profile').update({
      'uid': user.uid,
      'name': name,
      'email': email,
      'location': 'Phnom Penh, Koh Pich',
      'joinedDate': 'Joined May, 2026',
      'createdAt': ServerValue.timestamp,
    }).timeout(_requestTimeout);

    return credential.user;
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth
        .sendPasswordResetEmail(email: email)
        .timeout(_requestTimeout);
  }

  String getReadableAuthError(Object error) {
    if (error is TimeoutException) {
      return 'The request is taking too long. Check your connection and try again.';
    }

    if (error is FirebaseException && error.code == 'permission-denied') {
      return 'Account created, but saving your profile was blocked by database rules.';
    }

    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'The email or password is incorrect.';
        case 'email-already-in-use':
          return 'An account already exists with this email.';
        case 'weak-password':
          return 'Please use a stronger password.';
        case 'network-request-failed':
          return 'Network error. Check your connection and try again.';
        default:
          return error.message ?? 'Authentication failed. Please try again.';
      }
    }

    return 'Something went wrong. Please try again.';
  }
}
