import 'package:flutter_test/flutter_test.dart';
import 'package:fumble/core/navigation/app_nav_index.dart';
import 'package:fumble/core/navigation/app_routes.dart';
import 'package:fumble/core/navigation/onboarding_gate.dart';
import 'package:fumble/core/config/app_config.dart';
import 'package:fumble/data/models/user_profile.dart';
import 'package:fumble/services/fumble/flumble_qr.dart';

void main() {
  test('Route table includes FLUMBLE V1 paths', () {
    expect(AppRoutes.routes.containsKey(AppRoutes.splash), isTrue);
    expect(AppRoutes.routes.containsKey(AppRoutes.login), isTrue);
    expect(AppRoutes.routes.containsKey(AppRoutes.signup), isTrue);
    expect(AppRoutes.routes.containsKey(AppRoutes.main), isTrue);
    expect(AppRoutes.routes.containsKey(AppRoutes.qrScanner), isTrue);
    expect(AppRoutes.routes.containsKey(AppRoutes.fumblePreview), isTrue);
    expect(AppRoutes.routes.containsKey(AppRoutes.settings), isTrue);
    expect(AppRoutes.routes.containsKey(AppRoutes.onboardingPhoto), isTrue);
    expect(AppRoutes.routes.containsKey(AppRoutes.onboardingPhone), isTrue);
    expect(AppRoutes.routes.containsKey('/onboarding-data'), isFalse);
  });

  test('Exactly three bottom tabs', () {
    expect(AppNavIndex.tabCount, 3);
    expect(AppNavIndex.flumble, 0);
    expect(AppNavIndex.myFlumble, 1);
    expect(AppNavIndex.connections, 2);
  });

  test('App branding', () {
    expect(AppConfig.displayName, 'Flumble');
    expect(AppConfig.androidApplicationId, 'com.fumble.app');
  });

  test('QR payload parsing', () {
    expect(FlumbleQr.parse('flumble:ABC123DEF456'), 'ABC123DEF456');
    expect(FlumbleQr.parse('not-a-code'), isNull);
    expect(FlumbleQr.build('abc123def456'), 'flumble:ABC123DEF456');
  });

  test('OnboardingGate uses photo then phone only', () {
    expect(OnboardingGate.totalSteps, 2);
    expect(OnboardingGate.routeFor(null), AppRoutes.onboardingPhoto);
    expect(OnboardingGate.routeFor(_profile()), AppRoutes.onboardingPhoto);
    expect(
      OnboardingGate.routeFor(_profile(photoUrl: 'base64')),
      AppRoutes.onboardingPhone,
    );
    expect(
      OnboardingGate.routeFor(_profile(photoUrl: 'base64', phone: '+15551234567')),
      AppRoutes.main,
    );
    expect(
      OnboardingGate.routeFor(_profile(phone: '+15551234567')),
      AppRoutes.onboardingPhoto,
    );
  });
}

UserProfile _profile({
  String? photoUrl,
  String? phone,
}) {
  return UserProfile(
    uid: 'u1',
    name: 'Ada',
    email: 'ada@example.com',
    flumbleCode: 'ABC123DEF456',
    photoUrl: photoUrl,
    phone: phone,
  );
}
