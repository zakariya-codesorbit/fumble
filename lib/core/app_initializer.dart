import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../data/db/local_prefs.dart';
import '../firebase_options.dart';
import '../services/analytics/analytics_service.dart';
import '../services/crashlytics/crashlytics_service.dart';
import '../services/network/connection_manager.dart';
import 'config/app_config.dart';

/// Post-launch Firebase and platform warm-up.
abstract final class AppInitializer {
  AppInitializer._();

  static bool _firebaseReady = false;

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

        // iOS Keychain keeps Firebase Auth after uninstall; SharedPreferences
        // do not. Clear the orphaned session on a true fresh install.
        await _clearOrphanedAuthIfFreshInstall();

        await Future.wait([
          AnalyticsService.instance.initialize(),
          CrashlyticsService.instance.initialize(),
          // App Check is optional until the API + debug tokens are set up
          // in Firebase Console. Skipping avoids noisy 403s on Spark projects.
          // AppCheckService.instance.initialize(),
        ]);
      }
    } catch (e, st) {
      debugPrint('[AppInitializer] initialize failed: $e\n$st');
    }
  }

  static Future<void> _clearOrphanedAuthIfFreshInstall() async {
    try {
      if (!await LocalPrefs.isFreshInstall()) return;

      if (FirebaseAuth.instance.currentUser != null) {
        debugPrint(
          '[AppInitializer] fresh install with Keychain auth — signing out',
        );
        await FirebaseAuth.instance.signOut();
      }
      await LocalPrefs.clear();
      await _deleteLocalDatabase();
      await LocalPrefs.markInstall();
    } catch (e, st) {
      debugPrint('[AppInitializer] fresh-install cleanup failed: $e\n$st');
      try {
        await LocalPrefs.markInstall();
      } catch (_) {/* ignore */}
    }
  }

  static Future<void> _deleteLocalDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, AppConfig.databaseFileName);
      await deleteDatabase(path);
    } catch (_) {/* ignore */}
  }
}
