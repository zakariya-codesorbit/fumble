import 'package:flutter/material.dart';

import 'colors.dart';

/// Font / weight helpers (Medico-compatible API).
abstract final class AppStyle {
  AppStyle._();

  static const List<String> fontFamilyFallback = <String>[
    '.SF Pro Text',
    'SF Pro Text',
    'Inter',
    'Roboto',
    'sans-serif',
  ];

  static const FontWeight w100 = FontWeight.w100;
  static const FontWeight w200 = FontWeight.w200;
  static const FontWeight w300 = FontWeight.w300;
  static const FontWeight w400 = FontWeight.w400;
  static const FontWeight w500 = FontWeight.w500;
  static const FontWeight w600 = FontWeight.w600;
  static const FontWeight w700 = FontWeight.w700;
  static const FontWeight w800 = FontWeight.w800;
  static const FontWeight w900 = FontWeight.w900;
  static const FontWeight bold = FontWeight.bold;

  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusSheet = 20;
  static const double radiusPill = 28;
  static const double fumbleButtonSize = 260;
  static const double fumbleButtonStroke = 2;
  static const double flumbleQrSize = 240;
  static const double flumbleQrRadiusFactor = 0.18;
  static const double flumbleScanCutout = 268;
  static const double connectionAvatar = 44;
  static const double bottomNavHeight = 64;

  static final TextStyle appbarTextStyle = TextStyle(
    color: AppColors.gold,
    fontSize: 18,
    fontWeight: w700,
    letterSpacing: 3,
    fontFamilyFallback: fontFamilyFallback,
  );
}
