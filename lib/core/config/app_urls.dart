/// Centralized URLs and external links.
abstract final class AppUrls {
  AppUrls._();

  static const String privacyPolicyUrl = '';
  static const String termsOfServiceUrl = '';
  static const String supportEmail = '';

  static const String playStorePackageId = 'com.fumble.app';
  static const String playStoreWebUrl =
      'https://play.google.com/store/apps/details?id=$playStorePackageId';
  static const String playStoreMarketUrl =
      'market://details?id=$playStorePackageId';

  /// Replace with the published App Store ID when available.
  static const String iosAppId = '0000000000';
  static String get appStoreReviewUrl =>
      'https://apps.apple.com/app/id$iosAppId?action=write-review';
}
