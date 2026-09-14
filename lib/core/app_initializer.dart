import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../firebase_options.dart';
import '../services/analytics/analytics_service.dart';
import '../services/crashlytics/crashlytics_service.dart';
import '../services/network/connection_manager.dart';
import '../services/notifications/notification_service.dart';
import '../services/offline/offline_fumble_queue.dart';

/// Post-launch Firebase and platform warm-up.
abstract final class AppInitializer {
  AppInitializer._();

  static bool _firebaseReady = false;
  static final OfflineFumbleQueue offlineQueue = OfflineFumbleQueue();
  static final NotificationService notifications = NotificationService();

  static bool get isFirebaseReady => _firebaseReady;

  static Future<void> initialize() async {
    try {
      await SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      ConnectionManager().initialize();

      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        _firebaseReady = true;

        await Future.wait([
          AnalyticsService.instance.initialize(),
          CrashlyticsService.instance.initialize(),
          // App Check is optional until the API + debug tokens are set up
          // in Firebase Console. Skipping avoids noisy 403s on Spark projects.
          // AppCheckService.instance.initialize(),
        ]);

        await notifications.initialize();
        offlineQueue.start();
      }
    } catch (e, st) {
      debugPrint('[AppInitializer] initialize failed: $e\n$st');
    }
  }
}
