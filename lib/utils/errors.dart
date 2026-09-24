import 'dart:async';

import 'package:firebase_core/firebase_core.dart';

/// An error with a message that can be shown to the user as-is.
class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Turns any error into a short, readable message.
String friendlyError(Object error) {
  if (error is AppException) return error.message;
  if (error is TimeoutException) return 'The request timed out. Please try again.';
  if (error is FirebaseException) {
    switch (error.code) {
      case 'unavailable':
      case 'network-request-failed':
        return 'Server not reachable. Please check your internet.';
      case 'permission-denied':
        return 'Permission denied. Check your Firestore rules.';
    }
    return error.message ?? 'Something went wrong (${error.code}).';
  }
  return 'Something went wrong. Please try again.';
}
