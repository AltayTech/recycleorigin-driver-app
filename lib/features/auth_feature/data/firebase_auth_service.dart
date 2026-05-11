import 'dart:async';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:recycleorigindriver/core/config/app_config.dart';
import 'package:recycleorigindriver/core/network/urls.dart';
import 'package:recycleorigindriver/core/storage/secure_storage.dart';

/// Result of a successful Firebase exchange. Contains the backend access /
/// refresh tokens and the canonical user record from Postgres.
class FirebaseAuthResult {
  const FirebaseAuthResult({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final Map<String, dynamic> user;

  bool get emailVerified => user['email_verified'] == true;
  String get role => (user['role'] as String?) ?? '';
  String get provider => (user['auth_provider'] as String?) ?? '';
}

/// Stable error codes that callers can map to localized messages.
class AuthErrorCodes {
  static const wrongPassword = 'wrong-password';
  static const userNotFound = 'user-not-found';
  static const invalidEmail = 'invalid-email';
  static const emailAlreadyInUse = 'email-already-in-use';
  static const weakPassword = 'weak-password';
  static const networkRequestFailed = 'network-request-failed';
  static const cancelled = 'cancelled';
  static const noCurrentUser = 'no-current-user';
  static const emailNotVerified = 'email-not-verified';
  static const exchangeFailed = 'exchange-failed';
  static const unknown = 'unknown';
}

class AuthException implements Exception {
  const AuthException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'AuthException($code): $message';
}

/// Wraps Firebase Auth + Google Sign-In and the backend exchange.
class FirebaseAuthService {
  static const String _appType = 'driver';
  static const String _serverClientId =
      '975667016332-422b23j24ar2afbrvg0vj9hq7i3k2nj7.apps.googleusercontent.com';

  FirebaseAuthService({
    fb.FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    Dio? exchangeClient,
  })  : _auth = auth ?? fb.FirebaseAuth.instance,
        _googleSignIn =
            googleSignIn ?? GoogleSignIn(serverClientId: _serverClientId),
        _exchangeClient = exchangeClient ?? _buildExchangeClient();

  final fb.FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final Dio _exchangeClient;

  static Dio _buildExchangeClient() {
    return Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  bool get hasFirebaseUser => _auth.currentUser != null;
  fb.User? get currentUser => _auth.currentUser;

  Future<FirebaseAuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return _exchangeWithBackend(cred.user!);
    } on fb.FirebaseAuthException catch (e) {
      throw _fromFirebase(e);
    } on Object catch (e, st) {
      developer.log('Email sign-in failed',
          name: 'driver.auth', error: e, stackTrace: st, level: 1000);
      throw _wrap(e);
    }
  }

  Future<FirebaseAuthResult> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user;
      if (user == null) {
        throw const AuthException(
          AuthErrorCodes.unknown,
          'Account creation returned no user',
        );
      }
      if (displayName != null && displayName.trim().isNotEmpty) {
        try {
          await user.updateDisplayName(displayName.trim());
        } catch (_) {}
      }
      try {
        await user.sendEmailVerification();
      } catch (e, st) {
        developer.log('Failed to send verification email',
            name: 'driver.auth', error: e, stackTrace: st, level: 900);
      }
      return _exchangeWithBackend(user);
    } on fb.FirebaseAuthException catch (e) {
      throw _fromFirebase(e);
    } on Object catch (e, st) {
      developer.log('Email register failed',
          name: 'driver.auth', error: e, stackTrace: st, level: 1000);
      throw _wrap(e);
    }
  }

  Future<FirebaseAuthResult> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException(
          AuthErrorCodes.cancelled,
          'Google sign-in was cancelled',
        );
      }
      final googleAuth = await googleUser.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final cred = await _auth.signInWithCredential(credential);
      return _exchangeWithBackend(cred.user!);
    } on fb.FirebaseAuthException catch (e) {
      throw _fromFirebase(e);
    } on AuthException {
      rethrow;
    } on Object catch (e, st) {
      developer.log('Google sign-in failed',
          name: 'driver.auth', error: e, stackTrace: st, level: 1000);
      throw _wrap(e);
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on fb.FirebaseAuthException catch (e) {
      throw _fromFirebase(e);
    } on Object catch (e) {
      throw _wrap(e);
    }
  }

  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException(
        AuthErrorCodes.noCurrentUser,
        'You must be signed in to resend verification',
      );
    }
    if (user.emailVerified) return;
    try {
      await user.sendEmailVerification();
    } on fb.FirebaseAuthException catch (e) {
      throw _fromFirebase(e);
    } on Object catch (e) {
      throw _wrap(e);
    }
  }

  Future<FirebaseAuthResult?> reloadAndExchangeIfVerified() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    await user.reload();
    final refreshed = _auth.currentUser;
    if (refreshed == null || !refreshed.emailVerified) return null;
    return _exchangeWithBackend(refreshed);
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (_) {}
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }

  Future<FirebaseAuthResult> _exchangeWithBackend(fb.User user) async {
    final idToken = await user.getIdToken(true);
    if (idToken == null || idToken.isEmpty) {
      throw const AuthException(
        AuthErrorCodes.exchangeFailed,
        'Failed to obtain Firebase ID token',
      );
    }
    try {
      final response = await _exchangeClient.post<Map<String, dynamic>>(
        Urls.firebaseExchangePath,
        data: {
          'id_token': idToken,
          'app_type': _appType,
        },
      );
      final body = response.data ?? const <String, dynamic>{};
      final access = (body['access_token'] ?? body['token']) as String? ?? '';
      final refresh = (body['refresh_token'] as String?) ?? '';
      final userMap =
          (body['user'] as Map<String, dynamic>?) ?? <String, dynamic>{};
      if (access.isEmpty) {
        throw const AuthException(
          AuthErrorCodes.exchangeFailed,
          'Backend did not return an access token',
        );
      }
      await SecureStorage.saveAccessToken(access);
      if (refresh.isNotEmpty) {
        await SecureStorage.saveRefreshToken(refresh);
      }
      await SecureStorage.saveLoginStatus(true);
      return FirebaseAuthResult(
        accessToken: access,
        refreshToken: refresh,
        user: userMap,
      );
    } on DioException catch (e) {
      throw AuthException(
        AuthErrorCodes.exchangeFailed,
        e.response?.data?.toString() ?? e.message ?? 'Backend exchange failed',
      );
    }
  }

  AuthException _fromFirebase(fb.FirebaseAuthException e) {
    return AuthException(e.code, e.message ?? e.code);
  }

  AuthException _wrap(Object error) {
    if (error is AuthException) return error;
    return AuthException(AuthErrorCodes.unknown, error.toString());
  }
}
