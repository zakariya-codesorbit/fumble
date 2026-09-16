import 'package:flutter/services.dart';

/// FLUMBLE design tokens — dark theme only.
///
/// Semantic aliases follow the Medico AppColors naming so both apps
/// share the same developer vocabulary.
abstract final class AppColors {
  AppColors._();

  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color clear = Color(0x00000000);

  static const Color background = Color(0xFF000000);
  static const Color navBar = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF0A0A0A);
  static const Color surfaceElevated = Color(0xFF141414);
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldMuted = Color(0xFFB8962E);
  static const Color goldDeep = Color(0xFFB8860B);
  static const Color qrBackground = Color(0xFF080808);
  static const Color qrGround = Color(0xFFFFF6E4);
  static const Color qrModule = Color(0xFF4A3C0A);
  static const Color softGray = Color(0xFF8A8A8A);
  static const Color softGrayDim = Color(0xFF5C5C5C);
  static const Color border = Color(0x1AFFFFFF);
  static const Color error = Color(0xFFE85D5D);
  static const Color success = Color(0xFF3DDC97);
  static const Color inputFill = Color(0xFF121212);

  static const Color backgroundColor = background;
  static const Color surfaceColor = surface;
  static const Color cardColor = surfaceElevated;
  static const Color surfaceSecondaryColor = surfaceElevated;
  static const Color surfaceTertiaryColor = surfaceElevated;
  static const Color primaryColor = gold;
  static const Color primaryForegroundColor = background;
  static const Color primaryTextColor = white;
  static const Color secondaryTextColor = softGray;
  static const Color iconColor = softGray;
  static const Color errorColor = error;
  static const Color errorForegroundColor = white;
  static const Color successColor = success;
  static const Color borderColor = border;
  static const Color inputFillColor = inputFill;
  static const Color primaryText = white;
  static const Color secondaryText = softGray;
  static const Color primary = gold;

  static const SystemUiOverlayStyle statusBar = SystemUiOverlayStyle(
    statusBarColor: background,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: navBar,
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarDividerColor: navBar,
  );

  static const SystemUiOverlayStyle statusBarDark = statusBar;

  static const SystemUiOverlayStyle statusBarTransparent = SystemUiOverlayStyle(
    statusBarColor: clear,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: navBar,
    systemNavigationBarIconBrightness: Brightness.light,
  );
}
