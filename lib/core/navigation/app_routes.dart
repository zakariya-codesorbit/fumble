import 'package:flutter/material.dart';

import 'package:fumble/utils/constant.dart';
import 'package:fumble/view/screens/auth_screen/forgot_password_screen.dart';
import 'package:fumble/view/screens/auth_screen/login_screen.dart';
import 'package:fumble/view/screens/auth_screen/signup_screen.dart';
import 'package:fumble/view/screens/onboarding_screen/phone_number_screen.dart';
import 'package:fumble/view/screens/onboarding_screen/upload_photo_screen.dart';
import 'package:fumble/view/screens/connections_screen/add_someone_screen.dart';
import 'package:fumble/view/screens/connections_screen/connection_detail_screen.dart';
import 'package:fumble/view/screens/connections_screen/connections_screen.dart';
import 'package:fumble/view/screens/connections_screen/fumble_playground_detail_screen.dart';
import 'package:fumble/view/screens/connections_screen/half_fumble_detail_screen.dart';
import 'package:fumble/view/screens/connections_screen/invitation_accept_screen.dart';
import 'package:fumble/view/screens/fumble_screen/fumble_screen.dart';
import 'package:fumble/view/screens/fumble_screen/fumble_scanner_screen.dart';
import 'package:fumble/view/screens/fumble_screen/fumble_preview_screen.dart';
import 'package:fumble/view/screens/main_screen/main_screen.dart';
import 'package:fumble/view/screens/my_fumble_screen/my_fumble_screen.dart';
import 'package:fumble/view/screens/setting_screen/legal_webview_screen.dart';
import 'package:fumble/view/screens/setting_screen/setting_screen.dart';
import 'package:fumble/view/screens/splash_screen/splash_screen.dart';

/// Named routes for fumble.
abstract final class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String onboardingPhoto = '/onboarding-photo';
  static const String onboardingPhone = '/onboarding-phone';
  static const String main = '/main';
  static const String fumble = '/fumble';
  static const String myfumble = '/my-fumble';
  static const String connections = '/connections';
  static const String connectionDetail = '/connection-detail';
  static const String halfFumbleDetail = '/half-fumble-detail';
  static const String fumblePlaygroundDetail = '/fumble-playground-detail';
  static const String addSomeone = '/add-someone';
  static const String invitationAccept = '/invitation-accept';
  static const String fumbleScanner = '/fumble-scanner';
  static const String fumblePreview = '/fumble-preview';
  static const String settings = '/settings';
  static const String privacyPolicy = '/privacy-policy';
  static const String terms = '/terms';

  static const String initial = splash;

  static Map<String, WidgetBuilder> get routes => <String, WidgetBuilder>{
    splash: (_) => const SplashScreen(),
    login: (_) => const LoginScreen(),
    signup: (_) => const SignupScreen(),
    forgotPassword: (_) => const ForgotPasswordScreen(),
    onboardingPhoto: (_) => const UploadPhotoScreen(),
    onboardingPhone: (_) => const PhoneNumberScreen(),
    main: (_) => const MainScreen(),
    fumble: (_) => const FumbleScreen(),
    myfumble: (_) => const MyFumbleScreen(),
    connections: (_) => const ConnectionsScreen(),
    connectionDetail: (context) {
      final peerUid = ModalRoute.of(context)?.settings.arguments as String?;
      return ConnectionDetailScreen(peerUid: peerUid ?? '');
    },
    halfFumbleDetail: (context) {
      final halfFumbleId =
          ModalRoute.of(context)?.settings.arguments as String?;
      return HalfFumbleDetailScreen(halfFumbleId: halfFumbleId ?? '');
    },
    fumblePlaygroundDetail: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      final adventureId = args is FumblePlaygroundDetailArgs
          ? args.adventureId
          : (args is String ? args : '');
      return FumblePlaygroundDetailScreen(adventureId: adventureId);
    },
    addSomeone: (_) => const AddSomeoneScreen(),
    invitationAccept: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as InvitationAcceptArgs?;
      return InvitationAcceptScreen(
        invitationId: args?.invitationId ?? '',
        token: args?.token,
      );
    },
    fumbleScanner: (_) => const FumbleScannerScreen(),
    fumblePreview: (_) => const FumblePreviewScreen(),
    settings: (_) => const SettingScreen(),
    privacyPolicy: (_) => const LegalWebViewScreen(
      title: AppConstant.privacyPolicy,
      isPrivacy: true,
    ),
    terms: (_) => const LegalWebViewScreen(
      title: AppConstant.termsAndConditions,
      isPrivacy: false,
    ),
  };
}
