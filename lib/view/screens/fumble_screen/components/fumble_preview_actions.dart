import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:fumble/data/repositories/fumble_code_repository.dart';
import 'package:fumble/services/location/fumble_location_service.dart';
import 'package:fumble/services/network/connection_manager.dart';
import 'package:fumble/services/speech/voice_memory_service.dart';
import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/view/widgets/feedback/custom_snackbar.dart';

abstract final class FumblePreviewActions {
  FumblePreviewActions._();

  static Future<void> call(String? phone) async {
    final value = phone?.trim();
    if (value == null || value.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: value);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  static Future<void> text(String? phone) async {
    final value = phone?.trim();
    if (value == null || value.isEmpty) return;
    final uri = Uri(scheme: 'sms', path: value);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  static Future<void> loadDetails(WidgetRef ref) {
    return ref.read(fumbleNotifierProvider.notifier).loadPreviewDetails();
  }

  static void cancel(WidgetRef ref) {
    ref.read(fumbleNotifierProvider.notifier).cancel();
  }

  static Future<void> saveNoteAndFinish({
    required WidgetRef ref,
    required String note,
    String? fumblePlace,
  }) {
    return ref.read(fumbleNotifierProvider.notifier).saveNoteAndFinish(
          note: note,
          fumblePlace: fumblePlace,
        );
  }

  /// Toggles voice listening. Returns whether listening is active after the call.
  static Future<bool> toggleVoiceMemory({
    required WidgetRef ref,
    required TextEditingController noteController,
    required VoidCallback onChanged,
  }) async {
    final voice = ref.read(voiceMemoryServiceProvider);

    if (voice.isListening) {
      await voice.stop();
      onChanged();
      return false;
    }

    final result = await voice.start(
      currentNote: noteController.text,
      onTranscript: (text) {
        noteController.value = TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
        onChanged();
      },
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          onChanged();
        }
      },
      onError: (_) => onChanged(),
    );

    if (!result.isOk) {
      showAppToast(result.message, isError: true);
      if (result.failure == VoiceMemoryFailure.microphoneDenied ||
          result.failure == VoiceMemoryFailure.speechDenied) {
        // Offer settings when permanently blocked.
        final mic = await Permission.microphone.status;
        if (mic.isPermanentlyDenied) await openAppSettings();
      }
      onChanged();
      return false;
    }

    onChanged();
    return true;
  }

  static Future<void> stopVoiceMemory(WidgetRef ref) async {
    await ref.read(voiceMemoryServiceProvider).stop();
  }

  /// Meeting place for THE MOMENT: own GPS when allowed, else peer's published
  /// place. Returns null when neither is available (show hint instead).
  ///
  /// Callers must pass [peerUid] / [codes] before any `await` so [WidgetRef]
  /// is not used after the widget may have been disposed.
  static Future<String?> resolveMeetingPlace({
    required String peerUid,
    required FumbleCodeRepository codes,
  }) async {
    final coords = await FumbleLocationService.currentLocation();
    if (coords != null) {
      final label = await FumbleLocationService.placeLabel(coords);
      if (label != null && label.trim().isNotEmpty) return label.trim();
    }

    if (!ConnectionManager().isConnected) return null;
    final uid = peerUid.trim();
    if (uid.isEmpty) return null;

    try {
      final card = await codes.loadPublicProfile(uid);
      final place = card?.fumblePlace?.trim();
      if (place != null && place.isNotEmpty) return place;
    } catch (_) {}
    return null;
  }
}
