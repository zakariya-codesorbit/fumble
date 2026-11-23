import 'package:firebase_auth/firebase_auth.dart';

import '../../data/db/local_prefs.dart';
import '../../data/models/user_profile.dart';
import '../../data/repositories/user_repository.dart';
import '../../utils/constant.dart';
import '../analytics/analytics_service.dart';
import '../crashlytics/crashlytics_service.dart';

class AuthService {
  AuthService({
    FirebaseAuth? auth,
    required UserRepository userRepository,
    AnalyticsService? analytics,
    CrashlyticsService? crashlytics,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _users = userRepository,
        _analytics = analytics ?? AnalyticsService.instance,
        _crashlytics = crashlytics ?? CrashlyticsService.instance;

  final FirebaseAuth _auth;
  final UserRepository _users;
  final AnalyticsService _analytics;
  final CrashlyticsService _crashlytics;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Fires when the ID token changes (incl. after email verify + refresh).
  Stream<User?> get idTokenChanges => _auth.idTokenChanges();

  User? get currentUser => _auth.currentUser;

  bool get isAuthenticated => currentUser != null;

  bool get isEmailVerified => currentUser?.emailVerified == true;

  Future<void> reloadUser() async {
    final user = currentUser;
    if (user == null) return;
    await user.reload();
    // Force a fresh JWT so Firestore rules see email_verified == true.
    await _auth.currentUser?.getIdToken(true);
  }

  Future<void> sendEmailVerification() async {
    final user = currentUser;
    if (user == null || user.emailVerified) return;
    await user.sendEmailVerification();
  }

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
      try {
        await user.sendEmailVerification();
      } catch (_) {
        // Non-fatal — invite acceptance still checks emailVerified.
      }
      final profile = await _users.createUserProfile(
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
      await user.reload();
      final refreshed = _auth.currentUser ?? user;
      if (!refreshed.emailVerified) {
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message: AppConstant.authEmailNotVerified,
        );
      }
      await refreshed.getIdToken(true);
      await _crashlytics.setUserId(refreshed.uid);
      // If Auth succeeded earlier but profile write failed, create it now.
      final existing = await _users.loadUserProfile(refreshed.uid);
      if (existing == null) {
        await _users.createUserProfile(
          uid: refreshed.uid,
          name: refreshed.displayName?.trim().isNotEmpty == true
              ? refreshed.displayName!.trim()
              : (refreshed.email?.split('@').first ??
                  AppConstant.defaultUserName),
          email: refreshed.email ?? email,
        );
      } else {
        await _users.updateUserLastActive(refreshed.uid);
      }
      await _analytics.logLogin();
      return refreshed;
    } catch (e, st) {
      await _crashlytics.recordError(e, st, reason: 'auth_login_failed');
      rethrow;
    }
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> logout() async {
    await _auth.signOut();
    try {
      await LocalPrefs.clearUserProfile();
    } catch (_) {
      /* ignore */
    }
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
    await _users.deleteUserProfile(user.uid);
    await user.delete();
    try {
      await LocalPrefs.clearUserProfile();
    } catch (_) {
      /* ignore */
    }
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
        'email-not-verified' => AppConstant.authEmailNotVerified,
        'firestore-unavailable' =>
          error.message ?? AppConstant.firestoreUnavailableShort,
        _ => error.message ?? AppConstant.authFailed,
      };
    }
    return AppConstant.authFailed;
  }
}
