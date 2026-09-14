import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class CrashlyticsService {
  CrashlyticsService._();
  static final CrashlyticsService instance = CrashlyticsService._();

  Future<void> initialize() async {
    try {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
        !kDebugMode,
      );

      FlutterError.onError = (details) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    } catch (e) {
      debugPrint('[Crashlytics] init failed: $e');
    }
  }

  Future<void> setUserId(String? uid) async {
    try {
      await FirebaseCrashlytics.instance.setUserIdentifier(uid ?? '');
    } catch (_) {/* ignore */}
  }

  Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
    Map<String, String>? customKeys,
  }) async {
    try {
      final crashlytics = FirebaseCrashlytics.instance;
      if (customKeys != null) {
        for (final entry in customKeys.entries) {
          await crashlytics.setCustomKey(entry.key, entry.value);
        }
      }
      await crashlytics.recordError(
        exception,
        stackTrace,
        reason: reason,
        fatal: fatal,
      );
    } catch (e) {
      debugPrint('[Crashlytics] record failed: $e');
    }
  }
}
