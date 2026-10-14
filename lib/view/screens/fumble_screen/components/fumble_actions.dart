import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/data/db/local_prefs.dart';
import 'package:fumble/data/models/user_profile.dart';
import 'package:fumble/services/fumble/fumble_qr.dart';
import 'package:fumble/services/location/fumble_location_service.dart';
import 'package:fumble/state/providers/app_providers.dart';

abstract final class FumbleActions {
  FumbleActions._();

  static void openScanner(WidgetRef ref) {
    ref.read(fumbleNotifierProvider.notifier).startFumble();
  }

  static Future<UserProfile?> loadCachedProfile(WidgetRef ref) async {
    final uid = ref.read(authServiceProvider).currentUser?.uid;
    final profile = await LocalPrefs.loadUserProfile();
    if (profile != null && profile.uid == uid) return profile;
    return null;
  }

  static Future<void> publishLocation({
    required BuildContext context,
    required WidgetRef ref,
    required bool promptIfDenied,
  }) async {
    final uid = ref.read(authServiceProvider).currentUser?.uid;
    if (uid == null) return;

    final place = await FumbleLocationService.capture(
      context,
      promptIfDenied: promptIfDenied,
    );
    try {
      await ref
          .read(fumbleCodeRepositoryProvider)
          .publishPublicMeetingPlace(uid: uid, location: place);
    } catch (_) {
      // Non-blocking — fumble still works without published location.
    }
  }

  static String? qrPayload(UserProfile? profile) {
    if (profile == null) return null;
    final name = profile.name.trim();
    final uid = profile.uid.trim();
    if (uid.isEmpty || name.isEmpty) return null;
    return FumbleQr.build(userId: uid, name: name);
  }

  static Future<void> ensurePublicCreatedAt({
    required WidgetRef ref,
    required UserProfile profile,
  }) async {
    if (profile.fumbleCode.isEmpty) return;
    await ref.read(fumbleCodeRepositoryProvider).ensurePublicCreatedAt(
          code: profile.fumbleCode,
          createdAt: profile.createdAt,
        );
  }
}
