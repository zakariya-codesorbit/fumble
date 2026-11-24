/// Centralized URLs and external links.
abstract final class AppUrls {
  AppUrls._();

  static const String websiteOrigin = 'https://myfumble.com';
  static const String privacyPolicyUrl = '$websiteOrigin/privacy/';
  static const String termsOfServiceUrl = '$websiteOrigin/terms/';
  static const String deleteAccountUrl = '$websiteOrigin/delete-account/';
  static const String supportEmail = 'hello@myfumble.com';

  static const String playStorePackageId = 'com.olivermann.fumble';
  static const String playStoreWebUrl =
      'https://play.google.com/store/apps/details?id=$playStorePackageId';
  static const String playStoreMarketUrl =
      'market://details?id=$playStorePackageId';

  /// Replace with the published App Store ID when available.
  static const String iosAppId = '6838681831';
  static String get appStoreUrl =>
      'https://apps.apple.com/app/id$iosAppId';
  static String get appStoreReviewUrl =>
      'https://apps.apple.com/app/id$iosAppId?action=write-review';

  /// Custom scheme — opens Fumble when already installed (no website).
  static const String inviteScheme = 'fumble';
  static const String inviteHost = 'invite';

  /// Both store listings — share text must not assume invitee OS.
  static String get halfFumbleBothStoresText =>
      'Android: $playStoreWebUrl\niOS: $appStoreUrl';

  /// Deep link used only when Fumble is already installed.
  static String halfFumbleAppInviteUrl({
    required String invitationId,
    required String token,
  }) {
    return '$inviteScheme://$inviteHost/$invitationId?t=$token';
  }
}
