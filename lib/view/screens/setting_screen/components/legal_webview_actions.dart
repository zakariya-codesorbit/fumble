import 'package:fumble/core/config/app_config.dart';

abstract final class LegalWebViewActions {
  static Uri uri({required bool isPrivacy}) => Uri.parse(
        isPrivacy ? AppConfig.privacyPolicyUrl : AppConfig.termsOfServiceUrl,
      );
}
