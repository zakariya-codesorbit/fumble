import 'package:firebase_auth/firebase_auth.dart';

import '../../data/models/user_profile.dart';
import '../../data/repositories/user_repository.dart';
import '../../utils/constant.dart';
import '../analytics/analytics_service.dart';
import '../crashlytics/crashlytics_service.dart';

class AuthService {
  AuthService({
    FirebaseAuth? auth,
    UserRepository? userRepository,
    AnalyticsService? analytics,
    CrashlyticsService? crashlytics,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _users = userRepository ?? UserRepository(),
        _analytics = analytics ?? AnalyticsService.instance,
        _crashlytics = crashlytics ?? CrashlyticsService.instance;

  final FirebaseAuth _auth;
  final UserRepository _users;
  final AnalyticsService _analytics;
  final CrashlyticsService _crashlytics;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  bool get isAuthenticated => currentUser != null;

  Future<UserProfile> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-null',
          message: AppConstant.authAccountCreationFailed,
        );
      }
      await user.updateDisplayName(name.trim());
      final profile = await _users.createUser(
        uid: user.uid,
        name: name,
        email: email,
      );
      await _crashlytics.setUserId(user.uid);
      await _analytics.logSignup();
      return profile;
    } on FirebaseAuthException catch (e, st) {
      await _crashlytics.recordError(e, st, reason: 'auth_signup_failed');
      rethrow;
    } catch (e, st) {
      await _crashlytics.recordError(e, st, reason: 'auth_signup_profile_failed');
      // Auth user may already exist; surface a clear Firestore setup hint.
      final message = e.toString();
      if (message.contains('PERMISSION_DENIED') ||
          message.contains('Cloud Firestore API') ||
          message.contains('firestore.googleapis.com')) {
        throw FirebaseAuthException(
          code: 'firestore-unavailable',
          message: AppConstant.firestoreUnavailable,
        );
      }
      rethrow;
    }
  }

  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-null',
          message: AppConstant.authLoginFailed,
        );
      }
      await _crashlytics.setUserId(user.uid);
      // If Auth succeeded earlier but profile write failed, create it now.
      final existing = await _users.getUser(user.uid);
      if (existing == null) {
        await _users.createUser(
          uid: user.uid,
          name: user.displayName?.trim().isNotEmpty == true
              ? user.displayName!.trim()
              : (user.email?.split('@').first ?? AppConstant.defaultUserName),
          email: user.email ?? email,
        );
      } else {
        await _users.touchLastActive(user.uid);
      }
      await _analytics.logLogin();
      return user;
    } catch (e, st) {
      await _crashlytics.recordError(e, st, reason: 'auth_login_failed');
      rethrow;
    }
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> logout() async {
    final uid = currentUser?.uid;
    if (uid != null) {
      try {
        await _users
            .updateFcmToken(uid, null)
            .timeout(const Duration(seconds: 2));
      } catch (_) {/* best effort — never block sign-out */}
    }
    await _auth.signOut();
    try {
      await _crashlytics.setUserId(null);
    } catch (_) {/* ignore */}
  }

  Future<void> reauthenticate(String password) async {
    final user = currentUser;
    final email = user?.email;
    if (user == null || email == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: AppConstant.authNotSignedIn,
      );
    }
    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);
  }

  Future<void> deleteAccount({required String password}) async {
    final user = currentUser;
    if (user == null) return;
    await reauthenticate(password);
    await _users.deleteUserDoc(user.uid);
    await user.delete();
    await _crashlytics.setUserId(null);
  }

  String messageForAuthError(Object error) {
    if (error is FirebaseAuthException) {
      return switch (error.code) {
        'email-already-in-use' => AppConstant.authEmailInUse,
        'invalid-email' => AppConstant.authInvalidEmail,
        'weak-password' => AppConstant.authWeakPassword,
        'user-not-found' || 'wrong-password' || 'invalid-credential' =>
          AppConstant.authWrongCredentials,
        'too-many-requests' => AppConstant.authTooManyRequests,
        'network-request-failed' => AppConstant.authNetworkError,
        'requires-recent-login' => AppConstant.authRequiresRecentLogin,
        'firestore-unavailable' =>
          error.message ?? AppConstant.firestoreUnavailableShort,
        _ => error.message ?? AppConstant.authFailed,
      };
    }
    return AppConstant.authFailed;
  }
}
