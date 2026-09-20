import 'package:flutter/material.dart';

import 'package:fumble/utils/constant.dart';
import 'package:fumble/view/screens/auth_screen/forgot_password_screen.dart';
import 'package:fumble/view/screens/auth_screen/login_screen.dart';
import 'package:fumble/view/screens/auth_screen/signup_screen.dart';
import 'package:fumble/view/screens/onboarding_screen/phone_number_screen.dart';
import 'package:fumble/view/screens/onboarding_screen/upload_photo_screen.dart';
import 'package:fumble/view/screens/connections_screen/connections_screen.dart';
import 'package:fumble/view/screens/flumble_screen/flumble_screen.dart';
import 'package:fumble/view/screens/flumble_screen/fumble_preview_screen.dart';
import 'package:fumble/view/screens/flumble_screen/fumble_success_screen.dart';
import 'package:fumble/view/screens/flumble_screen/qr_scanner_screen.dart';
import 'package:fumble/view/screens/main_screen/main_screen.dart';
import 'package:fumble/view/screens/my_flumble_screen/edit_profile_screen.dart';
import 'package:fumble/view/screens/my_flumble_screen/my_flumble_screen.dart';
import 'package:fumble/view/screens/setting_screen/legal_webview_screen.dart';
import 'package:fumble/view/screens/setting_screen/setting_screen.dart';
import 'package:fumble/view/screens/splash_screen/splash_screen.dart';

/// Named routes for FLUMBLE.
abstract final class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String onboardingPhoto = '/onboarding-photo';
  static const String onboardingPhone = '/onboarding-phone';
  static const String main = '/main';
  static const String flumble = '/flumble';
  static const String myFlumble = '/my-flumble';
  static const String connections = '/connections';
  static const String qrScanner = '/qr-scanner';
  static const String fumblePreview = '/fumble-preview';
  static const String fumbleSuccess = '/fumble-success';
  static const String editProfile = '/edit-profile';
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
        flumble: (_) => const FlumbleScreen(),
        myFlumble: (_) => const MyFlumbleScreen(),
        connections: (_) => const ConnectionsScreen(),
        qrScanner: (_) => const QrScannerScreen(),
        fumblePreview: (_) => const FumblePreviewScreen(),
        fumbleSuccess: (_) => const FumbleSuccessScreen(),
        editProfile: (_) => const EditProfileScreen(),
        settings: (_) => const SettingScreen(),
        privacyPolicy: (_) => const LegalWebViewScreen(
              title: AppConstant.privacyPolicy,
              isPrivacy: true,
            ),
        terms: (_) => const LegalWebViewScreen(
              title: AppConstant.termsOfService,
              isPrivacy: false,
            ),
      };
}
