import '../../core/config/app_config.dart';

/// Pure QR payload helpers (no Firebase dependency).
abstract final class FlumbleQr {
  static String? parse(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    if (trimmed.startsWith(AppConfig.qrPrefix)) {
      final code = trimmed.substring(AppConfig.qrPrefix.length).trim();
      return _isValidCode(code) ? code.toUpperCase() : null;
    }

    if (_isValidCode(trimmed)) return trimmed.toUpperCase();
    return null;
  }

  static String build(String flumbleCode) =>
      '${AppConfig.qrPrefix}${flumbleCode.toUpperCase()}';

  static bool _isValidCode(String code) {
    final cleaned = code.trim();
    return RegExp(r'^[A-Za-z0-9]{8,32}$').hasMatch(cleaned);
  }
}
