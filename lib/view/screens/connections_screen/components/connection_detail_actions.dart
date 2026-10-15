import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:fumble/core/navigation/router_navigator.dart';
import 'package:fumble/data/models/connection.dart';
import 'package:fumble/data/models/public_fumble_profile.dart';
import 'package:fumble/services/network/connection_manager.dart';
import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/view/widgets/feedback/custom_snackbar.dart';

class ConnectionPublicExtras {
  const ConnectionPublicExtras({this.aboutMe, this.location});

  final String? aboutMe;
  final String? location;
}

abstract final class ConnectionDetailActions {
  ConnectionDetailActions._();

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

  static Future<ConnectionPublicExtras?> loadPublicExtras({
    required WidgetRef ref,
    required String peerUid,
  }) async {
    if (!ConnectionManager().isConnected) return null;
    final uid = peerUid.trim();
    if (uid.isEmpty) return null;

    // Capture before any await — [ref] must not be used after dispose.
    final codes = ref.read(fumbleCodeRepositoryProvider);

    try {
      final PublicFumbleProfile? card = await codes.loadPublicProfile(uid);
      if (card == null) return null;
      final aboutMe = card.aboutMe?.trim();
      final location = card.fumblePlace?.trim() ?? card.location?.trim();
      return ConnectionPublicExtras(
        aboutMe: (aboutMe != null && aboutMe.isNotEmpty) ? aboutMe : null,
        location: (location != null && location.isNotEmpty) ? location : null,
      );
    } catch (_) {
      return null;
    }
  }

  /// Returns `true` when note/place were saved and the screen should pop.
  static Future<bool> saveNoteAndPop({
    required WidgetRef ref,
    required Connection connection,
    required String note,
    String? fumblePlace,
  }) async {
    final uid = ref.read(authServiceProvider).currentUser?.uid;
    if (uid == null) {
      showAppToast(AppConstant.authPleaseLogIn, isError: true);
      return false;
    }

    try {
      final place = fumblePlace?.trim();
      final placeToSave = (place != null &&
              place.isNotEmpty &&
              place != AppConstant.nearExchangeLocation)
          ? place
          : null;

      await ref.read(connectionRepositoryProvider).updateConnectionMemory(
            ownerUid: uid,
            peerUid: connection.peerUid,
            note: note,
            fumblePlace: placeToSave,
          );
      pop();
      return true;
    } catch (_) {
      showAppToast(AppConstant.somethingWrong, isError: true);
      return false;
    }
  }
}
