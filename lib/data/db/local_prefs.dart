import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight local preferences for FLUMBLE.
abstract final class LocalPrefs {
  static const _notificationPromptedKey = 'notification_prompted';
  static const _lastFcmTokenKey = 'last_fcm_token';

  static Future<bool> get notificationPrompted async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationPromptedKey) ?? false;
  }

  static Future<void> setNotificationPrompted(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationPromptedKey, value);
  }

  static Future<String?> get lastFcmToken async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastFcmTokenKey);
  }

  static Future<void> setLastFcmToken(String? token) async {
    final prefs = await SharedPreferences.getInstance();
    if (token == null) {
      await prefs.remove(_lastFcmTokenKey);
    } else {
      await prefs.setString(_lastFcmTokenKey, token);
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
