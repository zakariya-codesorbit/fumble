import 'app_urls.dart';

/// Branding and app-wide configuration for Fumble.
abstract final class AppConfig {
  static const String displayName = 'Fumble';
  static const String brandUpper = 'FUMBLE';

  static const String androidApplicationId = 'com.fumble.app';
  static const String iosBundleId = 'com.fumble.app';

  static const String supportEmail = AppUrls.supportEmail;
  static const String privacyPolicyUrl = AppUrls.privacyPolicyUrl;
  static const String termsOfServiceUrl = AppUrls.termsOfServiceUrl;

  static const String databaseFileName = 'fumble.db';

  /// Legacy code-only prefix. Current QR payloads are versioned JSON.
  static const String qrPrefix = 'fumble:';

  static const int maxProfilePhotoBytes = 5 * 1024 * 1024;
  static const int profilePhotoQuality = 80;
  static const int profilePhotoMaxWidth = 1024;

  static const Duration splashMinDuration = Duration(milliseconds: 1200);
  static const Duration sessionExpiry = Duration(minutes: 10);
}
