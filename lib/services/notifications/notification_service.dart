import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../data/db/local_prefs.dart';
import '../../data/repositories/user_repository.dart';
import '../auth/auth_service.dart';
import '../crashlytics/crashlytics_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // No-op for V1 — connection push is informational.
}

class NotificationService {
  NotificationService({
    FirebaseMessaging? messaging,
    UserRepository? users,
    AuthService? auth,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _users = users ?? UserRepository(),
        _auth = auth ?? AuthService();

  final FirebaseMessaging _messaging;
  final UserRepository _users;
  final AuthService _auth;
  StreamSubscription<String>? _tokenRefreshSub;

  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  /// Request permission at a meaningful point (after first successful fumble).
  Future<bool> requestPermissionIfNeeded() async {
    final already = await LocalPrefs.notificationPrompted;
    if (already) {
      await syncToken();
      return true;
    }

    try {
      if (Platform.isAndroid) {
        final status = await Permission.notification.request();
        await LocalPrefs.setNotificationPrompted(true);
        if (!status.isGranted) return false;
      } else {
        final settings = await _messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        await LocalPrefs.setNotificationPrompted(true);
        if (settings.authorizationStatus == AuthorizationStatus.denied) {
          return false;
        }
      }
      await syncToken();
      return true;
    } catch (e, st) {
      await CrashlyticsService.instance.recordError(
        e,
        st,
        reason: 'notification_permission_failed',
      );
      return false;
    }
  }

  Future<void> syncToken() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    try {
      final token = await _messaging.getToken();
      if (token == null) return;
      final last = await LocalPrefs.lastFcmToken;
      if (last == token) return;
      await _users.updateFcmToken(uid, token);
      await LocalPrefs.setLastFcmToken(token);

      _tokenRefreshSub?.cancel();
      _tokenRefreshSub = _messaging.onTokenRefresh.listen((newToken) async {
        final currentUid = _auth.currentUser?.uid;
        if (currentUid == null) return;
        await _users.updateFcmToken(currentUid, newToken);
        await LocalPrefs.setLastFcmToken(newToken);
      });
    } catch (e) {
      debugPrint('[FCM] syncToken failed: $e');
    }
  }

  Future<void> clearTokenOnLogout() async {
    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub = null;
    await LocalPrefs.setLastFcmToken(null);
    try {
      await _messaging.deleteToken().timeout(const Duration(seconds: 2));
    } catch (_) {/* ignore */}
  }
}
