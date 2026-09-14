import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';

/// App Check — intentionally off until you enable the App Check API and
/// register debug tokens in Firebase Console.
///
/// Call [initialize] only after:
/// 1. Enabling App Check for the Android/iOS apps
/// 2. Registering the debug token printed in logcat (debug builds)
class AppCheckService {
  AppCheckService._();
  static final AppCheckService instance = AppCheckService._();

  static const bool enabled = false;

  Future<void> initialize() async {
    if (!enabled) {
      debugPrint('[AppCheck] skipped (not enabled for this environment)');
      return;
    }
    try {
      await FirebaseAppCheck.instance.activate(
        providerAndroid: kDebugMode
            ? const AndroidDebugProvider()
            : const AndroidPlayIntegrityProvider(),
        providerApple: kDebugMode
            ? const AppleDebugProvider()
            : const AppleAppAttestProvider(),
      );
    } catch (e) {
      debugPrint('[AppCheck] init failed: $e');
    }
  }
}
