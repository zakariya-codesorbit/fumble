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

  static Future<void> whatsApp(String? phone) async {
    final digits = phone?.replaceAll(RegExp(r'\D'), '') ?? '';
    if (digits.isEmpty) return;
    final uri = Uri.parse('https://wa.me/$digits');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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

  /// Label for the preview location field.
  /// 1) Scanner GPS → geocode
  /// 2) Else peer published coords → geocode (same place saved to Firebase)
  ///
  /// Pass [peerUid] / [codes] before any `await` so [WidgetRef] is not used
  /// after dispose.
  static Future<String?> resolveMeetingPlaceForPreview({
    required String peerUid,
    required FumbleCodeRepository codes,
  }) async {
    final ownCoords = await FumbleLocationService.currentLocation();
    if (ownCoords != null) {
      final label = await FumbleLocationService.placeLabel(ownCoords);
      final trimmed = label?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        debugPrint('[FumblePreview] meeting place from OWN GPS: $trimmed');
        return trimmed;
      }
      debugPrint('[FumblePreview] own GPS ok but geocode empty');
    }

    if (!ConnectionManager().isConnected) {
      debugPrint('[FumblePreview] offline — no peer location fallback');
      return null;
    }
    final uid = peerUid.trim();
    if (uid.isEmpty) {
      debugPrint('[FumblePreview] peerUid empty — no peer location fallback');
      return null;
    }

    try {
      final card = await codes.loadPublicProfile(uid);
      if (card == null) {
        debugPrint('[FumblePreview] peer profile null for $uid');
        return null;
      }

      final peerCoords = card.fumbleLocation;
      if (peerCoords != null) {
        final label = await FumbleLocationService.placeLabel(peerCoords);
        final trimmed = label?.trim();
        if (trimmed != null && trimmed.isNotEmpty) {
          debugPrint('[FumblePreview] meeting place from PEER GPS: $trimmed');
          return trimmed;
        }
        debugPrint('[FumblePreview] peer GPS ok but geocode empty');
      } else {
        debugPrint('[FumblePreview] peer has no fumbleLocation');
      }

      final published = card.fumblePlace?.trim();
      if (published != null && published.isNotEmpty) {
        debugPrint('[FumblePreview] meeting place from peer fumblePlace: $published');
        return published;
      }
      debugPrint('[FumblePreview] peer has no fumblePlace either');
    } catch (e) {
      debugPrint('[FumblePreview] peer location load failed → $e');
    }
    return null;
  }
}
