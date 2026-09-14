import 'package:flutter_test/flutter_test.dart';
import 'package:fumble/core/navigation/app_nav_index.dart';
import 'package:fumble/core/navigation/app_routes.dart';
import 'package:fumble/core/config/app_config.dart';
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
    expect(AppRoutes.routes.containsKey('/onboardingScreen'), isFalse);
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
}
