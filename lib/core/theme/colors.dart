import 'package:flutter/services.dart';

/// fumble design tokens — dark theme only.
///
/// Use semantic names in UI: `textPrimary`, `surface`, `primary`, …
abstract final class AppColors {
  AppColors._();

  // ── Surfaces ──────────────────────────────────────────────────────
  static const Color clear = Color(0x00000000);

  /// Page / scaffold background.
  static const Color background = Color(0xFF0A0A0A);

  /// Bottom nav + app chrome.
  static const Color navBar = Color(0xFF0A0A0A);

  /// Card fill (warm charcoal).
  static const Color surface = Color(0xFF161511);

  /// Raised sheets / dialogs / selected chips.
  static const Color surfaceElevated = Color(0xFF1C1A16);

  /// Inset fields — pure black against warm cards.
  static const Color inputFill = Color(0xFF000000);

  /// Visible warm bronze card / input border.
  static const Color border = Color(0xFF3D3426);

  // ── Brand / accent ────────────────────────────────────────────────
  /// Primary brand gold / ochre.
  static const Color primary = Color(0xFFC9A03A);

  /// Dimmer gold for secondary accents + coin ring.
  static const Color primaryMuted = Color(0xFF7A5C2E);

  /// Ink on primary fills (button label, icon on gold chip).
  static const Color onPrimary = Color(0xFF000000);

  // ── Text ─────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF2F0E9);
  static const Color textSecondary = Color(0xFF8A8A8A);
  static const Color textTertiary = Color(0xFF8F8479);
  static const Color textDisabled = Color(0xFF5C5C5C);

  /// Cream numerals on the AI coins badge.
  static const Color textOnCoin = Color(0xFFF5E8C7);

  // ── Status ────────────────────────────────────────────────────────
  static const Color error = Color(0xFFE85D5D);
  static const Color success = Color(0xFF3DDC97);
  static const Color onError = textPrimary;

  // ── Feature-specific ──────────────────────────────────────────────
  static const Color whatsApp = Color(0xFF25D366);
  static const Color whatsAppMuted = Color(0xFF1E9E4F);
  static const Color qrBackground = Color(0xFF080808);
  static const Color qrGround = primary;
  static const Color qrModule = background;

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
