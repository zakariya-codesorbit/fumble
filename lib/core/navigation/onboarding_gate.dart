import 'package:fumble/core/navigation/app_routes.dart';
import 'package:fumble/data/models/user_profile.dart';

/// After login, signup, or splash: send the user to the first empty step.
/// Order: photo → phone → main.
abstract final class OnboardingGate {
  static const int photoStep = 1;
  static const int phoneStep = 2;
  static const int totalSteps = 2;

  static String routeFor(
    UserProfile? profile, {
    bool photoFilled = false,
    bool phoneFilled = false,
  }) {
    final hasPhoto = photoFilled || (profile?.hasPhoto ?? false);
    final hasPhone = phoneFilled || (profile?.hasPhone ?? false);

    if (!hasPhoto) return AppRoutes.onboardingPhoto;
    if (!hasPhone) return AppRoutes.onboardingPhone;
    return AppRoutes.main;
  }

  static bool isOnboardingRoute(String? routeName) {
    return routeName == AppRoutes.onboardingPhoto ||
        routeName == AppRoutes.onboardingPhone;
  }
}
