import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/auth_service.dart';

void main() {
  group('AuthService error mapping tests', () {
    test('maps email-already-in-use to friendly message', () {
      final error = FirebaseAuthException(
        code: 'email-already-in-use',
        message: 'The email address is already in use.',
      );
      expect(
        AuthService.getReadableAuthError(error),
        'This email is already registered. Please sign in instead.',
      );
    });

    test('maps invalid-email to friendly message', () {
      final error = FirebaseAuthException(
        code: 'invalid-email',
        message: 'The email is badly formatted.',
      );
      expect(
        AuthService.getReadableAuthError(error),
        'The email address entered is not valid.',
      );
    });

    test('maps weak-password to friendly message', () {
      final error = FirebaseAuthException(
        code: 'weak-password',
        message: 'Password is too weak.',
      );
      expect(
        AuthService.getReadableAuthError(error),
        'The password is too weak. Please use at least 6 characters.',
      );
    });

    test('maps invalid-credential to friendly message', () {
      final error = FirebaseAuthException(
        code: 'invalid-credential',
        message: 'Credentials invalid.',
      );
      expect(
        AuthService.getReadableAuthError(error),
        'Invalid email or password. Please check your credentials.',
      );
    });

    test('maps user-not-found to friendly message', () {
      final error = FirebaseAuthException(
        code: 'user-not-found',
        message: 'User not found.',
      );
      expect(
        AuthService.getReadableAuthError(error),
        'No account found with this email address.',
      );
    });

    test('maps network-request-failed to friendly message', () {
      final error = FirebaseAuthException(
        code: 'network-request-failed',
        message: 'Network error.',
      );
      expect(
        AuthService.getReadableAuthError(error),
        'Network error. Please check your internet connection.',
      );
    });

    test('falls back to error message or default text', () {
      final error = FirebaseAuthException(
        code: 'custom-error-code',
        message: 'Custom error occurred.',
      );
      expect(
        AuthService.getReadableAuthError(error),
        'Custom error occurred.',
      );
    });
  });

  group('AuthService safe defaults without active Firebase initialization', () {
    test('currentUser returns null safely without throwing', () {
      final service = AuthService();
      expect(service.currentUser, isNull);
    });

    test('authStateChanges stream is non-null safely without throwing', () {
      final service = AuthService();
      expect(service.authStateChanges, isNotNull);
    });
  });
}
