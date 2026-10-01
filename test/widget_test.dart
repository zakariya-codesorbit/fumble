import 'package:flutter_test/flutter_test.dart';
import 'package:fumble/core/navigation/app_nav_index.dart';
import 'package:fumble/core/navigation/app_routes.dart';
import 'package:fumble/core/navigation/onboarding_gate.dart';
import 'package:fumble/core/config/app_config.dart';
import 'package:fumble/data/models/connection.dart';
import 'package:fumble/data/models/user_profile.dart';
import 'package:fumble/services/fumble/fumble_qr.dart';

void main() {
  test('Route table includes fumble V1 paths', () {
    expect(AppRoutes.routes.containsKey(AppRoutes.splash), isTrue);
    expect(AppRoutes.routes.containsKey(AppRoutes.login), isTrue);
    expect(AppRoutes.routes.containsKey(AppRoutes.signup), isTrue);
    expect(AppRoutes.routes.containsKey(AppRoutes.main), isTrue);
    expect(AppRoutes.routes.containsKey(AppRoutes.fumbleScanner), isTrue);
    expect(AppRoutes.routes.containsKey(AppRoutes.fumbleShare), isTrue);
    expect(AppRoutes.routes.containsKey(AppRoutes.fumblePreview), isTrue);
    expect(AppRoutes.routes.containsKey(AppRoutes.settings), isTrue);
    expect(AppRoutes.routes.containsKey(AppRoutes.onboardingPhoto), isTrue);
    expect(AppRoutes.routes.containsKey(AppRoutes.onboardingPhone), isTrue);
    expect(AppRoutes.routes.containsKey('/onboarding-data'), isFalse);
  });

  test('Exactly three bottom tabs', () {
    expect(AppNavIndex.tabCount, 3);
    expect(AppNavIndex.fumble, 0);
    expect(AppNavIndex.myfumble, 1);
    expect(AppNavIndex.connections, 2);
  });

  test('App branding', () {
    expect(AppConfig.displayName, 'Fumble');
    expect(AppConfig.androidApplicationId, 'com.fumble.app');
  });

  test('QR payload is versioned contact data', () {
    final raw = FumbleQr.build(
      userId: 'abc123',
      name: 'Muhammad Zakariya',
      bio: 'Flutter Developer',
      phone: '+923001234567',
      email: 'ada@example.com',
    );
    final decoded = FumbleQr.decode(raw);

    expect(decoded.error, isNull);
    expect(decoded.payload?.version, 1);
    expect(decoded.payload?.userId, 'abc123');
    expect(decoded.payload?.name, 'Muhammad Zakariya');
    expect(decoded.payload?.bio, 'Flutter Developer');
    expect(decoded.payload?.phone, '+923001234567');
    expect(decoded.payload?.email, 'ada@example.com');
  });

  test('QR payload omits empty optional fields', () {
    final raw = FumbleQr.build(
      userId: 'abc123',
      name: 'Ada',
      bio: '  ',
      phone: '',
    );
    final decoded = FumbleQr.decode(raw);

    expect(decoded.payload?.bio, isNull);
    expect(decoded.payload?.phone, isNull);
    expect(raw.contains('bio'), isFalse);
    expect(raw.contains('phone'), isFalse);
  });

  test('QR validation reports payload errors', () {
    expect(FumbleQr.decode('not-a-code').error, QrDecodeError.invalid);
    expect(FumbleQr.decode('{').error, QrDecodeError.malformed);
    expect(
      FumbleQr.decode('{"version":2,"userId":"a","name":"Ada"}').error,
      QrDecodeError.unsupportedVersion,
    );
    expect(
      FumbleQr.decode('{"version":1,"name":"Ada"}').error,
      QrDecodeError.missingUserId,
    );
    expect(
      FumbleQr.decode('{"version":1,"userId":"abc"}').error,
      QrDecodeError.missingName,
    );
  });

  test('Existing remote connections default to synced', () {
    final connection = Connection.fromMap('peer1', {
      'peerUid': 'peer1',
      'name': 'Ada',
      'email': 'ada@example.com',
      'fumbledAt': DateTime.utc(2024, 1, 1),
    });

    expect(connection.syncStatus, SyncStatus.synced);
    expect(connection.name, 'Ada');
    expect(connection.email, 'ada@example.com');
    expect(connection.bio, isNull);
    expect(connection.phone, isNull);
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
      OnboardingGate.routeFor(
        _profile(photoUrl: 'base64', phone: '+15551234567'),
      ),
      AppRoutes.main,
    );
    expect(
      OnboardingGate.routeFor(_profile(phone: '+15551234567')),
      AppRoutes.onboardingPhoto,
    );
  });
}

UserProfile _profile({String? photoUrl, String? phone}) {
  return UserProfile(
    uid: 'u1',
    name: 'Ada',
    email: 'ada@example.com',
    fumbleCode: 'ABC123DEF456',
    photoUrl: photoUrl,
    phone: phone,
  );
}
