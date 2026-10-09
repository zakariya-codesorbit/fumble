import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:fumble/core/navigation/app_nav_index.dart';
import 'package:fumble/core/navigation/app_routes.dart';
import 'package:fumble/core/navigation/onboarding_gate.dart';
import 'package:fumble/core/config/app_config.dart';
import 'package:fumble/data/models/connection.dart';
import 'package:fumble/data/models/user_profile.dart';
import 'package:fumble/services/fumble/fumble_qr.dart';
import 'package:fumble/utils/avatar_svg.dart';

void main() {
  test('Route table includes fumble V1 paths', () {
    expect(AppRoutes.routes.containsKey(AppRoutes.splash), isTrue);
    expect(AppRoutes.routes.containsKey(AppRoutes.login), isTrue);
    expect(AppRoutes.routes.containsKey(AppRoutes.signup), isTrue);
    expect(AppRoutes.routes.containsKey(AppRoutes.main), isTrue);
    expect(AppRoutes.routes.containsKey(AppRoutes.fumbleScanner), isTrue);
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
    expect(AppConfig.appVersionName, '1.0.0');
    expect(AppConfig.appBuildNumber, 1);
    expect(AppConfig.databaseSchemaVersion, 1);
  });

  test('QR payload is encrypted and round-trips through Fumble', () {
    final raw = FumbleQr.build(
      userId: 'uid_abc',
      name: 'Muhammad Zakariya',
    );

    expect(raw.startsWith('fumble:4.'), isTrue);
    expect(raw.contains('uid_abc'), isFalse);
    expect(raw.contains('Muhammad'), isFalse);

    final decoded = FumbleQr.decode(raw);
    expect(decoded.error, isNull);
    expect(decoded.payload?.version, 4);
    expect(decoded.payload?.userId, 'uid_abc');
    expect(decoded.payload?.name, 'Muhammad Zakariya');
  });

  test('QR payload requires user id and name', () {
    final raw = FumbleQr.build(userId: 'uid_1', name: 'Ada');
    final decoded = FumbleQr.decode(raw);

    expect(decoded.payload?.userId, 'uid_1');
    expect(decoded.payload?.name, 'Ada');
  });

  test('QR validation reports payload errors', () {
    expect(FumbleQr.decode('not-a-code').error, QrDecodeError.invalid);
    expect(FumbleQr.decode('{').error, QrDecodeError.malformed);
    expect(
      FumbleQr.decode('{"version":3,"userId":"u","name":"Ada"}').error,
      QrDecodeError.unsupportedVersion,
    );
    expect(
      FumbleQr.decode('{"version":4,"name":"Ada"}').error,
      QrDecodeError.missingUserId,
    );
    expect(
      FumbleQr.decode('{"version":4,"userId":"u"}').error,
      QrDecodeError.missingName,
    );
    expect(
      FumbleQr.decode('fumble:4.not-valid-cipher').error,
      QrDecodeError.invalid,
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

  test('avatar stylesheets are copied onto the shapes', () {
    const raw = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 10 10">
<defs><style>.cls-1{fill:#fcc19c;}.cls-2{opacity:0.5;}.cls-3{mix-blend-mode:multiply;}</style></defs>
<g class="cls-2"><path class="cls-1" d="M0 0h10v10z"/></g>
</svg>
''';
    final prepared = inlineSvgClassStyles(raw);
    expect(prepared.contains('fill="#fcc19c"'), isTrue);
    expect(prepared.contains('opacity="0.5"'), isTrue);
    expect(prepared.contains('<style'), isFalse);
    expect(prepared.contains('mix-blend-mode'), isFalse);

    final avatar = inlineSvgClassStyles(
      File('assets/avatars/avatar-1.svg').readAsStringSync(),
    );
    expect(avatar.contains('fill="#fcc19c"'), isTrue);
    expect(avatar.contains('fill="#1b1012"'), isTrue);
    expect(avatar.contains('class="'), isFalse);
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
