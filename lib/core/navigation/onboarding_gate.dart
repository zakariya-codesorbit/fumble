import 'package:fumble/core/navigation/app_routes.dart';
import 'package:fumble/data/models/user_profile.dart';

/// After login, signup, or splash: send the user to the first empty step.
/// Filled steps are skipped. If every step is filled, go to home.
abstract final class OnboardingGate {
  static const int photoStep = 1;
  static const int phoneStep = 2;
  static const int dataStep = 3;
  static const int totalSteps = 3;

  static String routeFor(
    UserProfile? profile, {
    bool photoFilled = false,
    bool phoneFilled = false,
    bool detailsFilled = false,
  }) {
    final hasPhoto = photoFilled || (profile?.hasPhoto ?? false);
    final hasPhone = phoneFilled || (profile?.hasPhone ?? false);
    final hasDetails = detailsFilled || (profile?.hasProfileDetails ?? false);

    if (!hasPhoto) return AppRoutes.onboardingPhoto;
    if (!hasPhone) return AppRoutes.onboardingPhone;
    if (!hasDetails) return AppRoutes.onboardingData;
    return AppRoutes.main;
  }

  static bool isOnboardingRoute(String? routeName) {
    return routeName == AppRoutes.onboardingPhoto ||
        routeName == AppRoutes.onboardingPhone ||
        routeName == AppRoutes.onboardingData;
  }
}
