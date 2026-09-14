import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

import 'analytics_events.dart';

class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  FirebaseAnalytics? _analytics;
  FirebaseAnalyticsObserver? _observer;

  FirebaseAnalyticsObserver? get navigatorObserver => _observer;

  Future<void> initialize() async {
    try {
      _analytics = FirebaseAnalytics.instance;
      _observer = FirebaseAnalyticsObserver(analytics: _analytics!);
      await _analytics!.setAnalyticsCollectionEnabled(!kDebugMode || true);
    } catch (e) {
      debugPrint('[Analytics] init failed: $e');
    }
  }

  Future<void> log(String name, [Map<String, Object>? params]) async {
    try {
      await _analytics?.logEvent(name: name, parameters: params);
    } catch (e) {
      debugPrint('[Analytics] log failed ($name): $e');
    }
  }

  Future<void> logSignup() => log(AnalyticsEvents.authSignup);
  Future<void> logLogin() => log(AnalyticsEvents.authLogin);
  Future<void> logFumbleStarted() => log(AnalyticsEvents.fumbleStarted);
  Future<void> logQrScannerOpened() => log(AnalyticsEvents.qrScannerOpened);
  Future<void> logQrScanned() => log(AnalyticsEvents.qrScanned);
  Future<void> logFumblePreviewViewed() =>
      log(AnalyticsEvents.fumblePreviewViewed);
  Future<void> logFumbleConfirmed() => log(AnalyticsEvents.fumbleConfirmed);
  Future<void> logConnectionCreated() =>
      log(AnalyticsEvents.connectionCreated);
  Future<void> logMyFlumbleOpened() => log(AnalyticsEvents.myFlumbleOpened);
  Future<void> logConnectionsOpened() =>
      log(AnalyticsEvents.connectionsOpened);
  Future<void> logTabSelected(String tab) => log(
        AnalyticsEvents.tabSelected,
        {AnalyticsParams.tab: tab},
      );
}
