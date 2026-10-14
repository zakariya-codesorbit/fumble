import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:fumble/state/providers/app_providers.dart';

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
}
