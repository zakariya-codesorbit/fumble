import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

/// Lightweight local preferences for fumble.
abstract final class LocalPrefs {
  static const _onboardingCompletedKey = 'onboarding_completed';
  static const _profileKey = 'cached_user_profile';
  /// Survives only while the app is installed. Cleared on uninstall, unlike
  /// iOS Keychain (where Firebase Auth keeps the session).
  static const _installMarkerKey = 'install_marker_v1';

  /// `true` when this process is the first launch after a fresh install
  /// (SharedPreferences empty, Keychain may still hold Auth).
  static Future<bool> isFreshInstall() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_installMarkerKey) ?? false);
  }

  static Future<void> markInstall() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_installMarkerKey, true);
  }

  static Future<bool> get onboardingCompleted async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  static Future<void> setOnboardingCompleted(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, value);
  }

  static Future<void> saveUserProfile(UserProfile profile) async {
    if (profile.uid.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toCacheJson()));
  }

  static Future<UserProfile?> loadUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_profileKey);
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final profile = UserProfile.fromCacheJson(
        Map<String, dynamic>.from(decoded),
      );
      if (profile.uid.isEmpty) return null;
      return profile;
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
