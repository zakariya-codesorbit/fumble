import 'package:flutter/material.dart';

import 'package:fumble/utils/colors.dart';
import 'package:fumble/utils/style.dart';

abstract final class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        canvasColor: AppColors.background,
        primaryColor: AppColors.gold,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.gold,
          onPrimary: AppColors.background,
          secondary: AppColors.surfaceElevated,
          onSecondary: AppColors.white,
          surface: AppColors.surface,
          onSurface: AppColors.white,
          error: AppColors.error,
          onError: AppColors.white,
          outline: AppColors.border,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: AppColors.clear,
          shadowColor: AppColors.clear,
          centerTitle: true,
          systemOverlayStyle: AppColors.statusBar,
          titleTextStyle: AppStyle.appbarTextStyle,
        ),
        dividerColor: AppColors.border,
        splashColor: AppColors.gold.withValues(alpha: 0.08),
        highlightColor: AppColors.clear,
        dialogTheme: const DialogThemeData(
          backgroundColor: AppColors.surfaceElevated,
          elevation: 0,
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.surfaceElevated,
          elevation: 0,
          modalElevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.inputFill,
          hintStyle: TextStyle(
            fontSize: 14,
            fontWeight: AppStyle.w400,
            color: AppColors.softGray,
            fontFamilyFallback: AppStyle.fontFamilyFallback,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppStyle.radiusMd),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppStyle.radiusMd),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppStyle.radiusMd),
            borderSide: const BorderSide(color: AppColors.gold),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppStyle.radiusMd),
            borderSide: const BorderSide(color: AppColors.error),
          ),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      );
}
