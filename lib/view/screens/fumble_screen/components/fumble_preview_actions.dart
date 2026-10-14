import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

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
  }) {
    return ref
        .read(fumbleNotifierProvider.notifier)
        .saveNoteAndFinish(note: note);
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
}
