import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../utils/errors.dart';

/// Login with Firebase email/password. Firebase remembers the user,
/// so they stay logged in after closing the app.
class AuthState extends ChangeNotifier {
  AuthState() {
    _subscription = _auth.authStateChanges().listen((user) {
      _user = user;
      _ready = true;
      notifyListeners();
    });
  }

  final _auth = FirebaseAuth.instance;
  late final StreamSubscription<User?> _subscription;
  User? _user;
  bool _ready = false;

  /// False until Firebase has checked for a saved login.
  bool get ready => _ready;
  User? get user => _user;

  Future<void> login(String email, String password) => _run(() =>
      _auth.signInWithEmailAndPassword(email: email.trim(), password: password));

  Future<void> register(String email, String password) => _run(() => _auth
      .createUserWithEmailAndPassword(email: email.trim(), password: password));

  Future<void> logout() => _auth.signOut();

  Future<void> _run(Future<Object?> Function() action) async {
    try {
      await action().timeout(const Duration(seconds: 20));
    } on FirebaseAuthException catch (e) {
      throw AppException(_message(e.code));
    } on TimeoutException {
      throw const AppException('The request timed out. Please try again.');
    }
  }

  String _message(String code) => switch (code) {
        'invalid-email' => 'Please enter a valid email.',
        'invalid-credential' ||
        'wrong-password' ||
        'user-not-found' =>
          'Wrong email or password.',
        'email-already-in-use' => 'An account already exists with this email.',
        'weak-password' => 'Password must be at least 6 characters.',
        'network-request-failed' => 'No internet connection.',
        'too-many-requests' => 'Too many attempts. Please try again later.',
        'operation-not-allowed' =>
          'Email/Password login is not enabled in Firebase Console.',
        _ => 'Login failed ($code).',
      };

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
