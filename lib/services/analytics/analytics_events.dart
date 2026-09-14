import '../../core/navigation/app_nav_index.dart';

abstract final class AnalyticsEvents {
  static const String authSignup = 'auth_signup';
  static const String authLogin = 'auth_login';
  static const String fumbleStarted = 'fumble_started';
  static const String qrScannerOpened = 'qr_scanner_opened';
  static const String qrScanned = 'qr_scanned';
  static const String fumblePreviewViewed = 'fumble_preview_viewed';
  static const String fumbleConfirmed = 'fumble_confirmed';
  static const String connectionCreated = 'connection_created';
  static const String myFlumbleOpened = 'my_flumble_opened';
  static const String connectionsOpened = 'connections_opened';
  static const String tabSelected = 'tab_selected';
}

abstract final class AnalyticsParams {
  static const String tab = 'tab';

  static String tabNameForIndex(int index) => switch (index) {
        AppNavIndex.flumble => 'flumble',
        AppNavIndex.myFlumble => 'my_flumble',
        AppNavIndex.connections => 'connections',
        _ => 'unknown',
      };
}
