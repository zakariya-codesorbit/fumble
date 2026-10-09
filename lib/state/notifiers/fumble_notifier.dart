import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/core/navigation/app_nav_index.dart';
import 'package:fumble/core/navigation/app_routes.dart';
import 'package:fumble/core/navigation/router_navigator.dart';
import 'package:fumble/data/db/local_prefs.dart';
import 'package:fumble/data/models/fumble_preview.dart';
import 'package:fumble/services/analytics/analytics_service.dart';
import 'package:fumble/services/location/fumble_location_service.dart';
import 'package:fumble/services/network/connection_manager.dart';
import 'package:fumble/services/notifications/notification_service.dart';
import 'package:fumble/state/notifiers/bottom_navigation_notifier.dart';
import 'package:fumble/state/providers/service_providers.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/view/widgets/dialogs/loading_dialog.dart';
import 'package:fumble/view/widgets/feedback/custom_snackbar.dart';
import '../../services/fumble/fumble_qr.dart';

class FumbleState {
  const FumbleState({
    this.preview,
    this.isConfirming = false,
    this.isHandlingScan = false,
    this.isLoadingPreview = false,
  });

  final FumblePreview? preview;
  final bool isConfirming;
  final bool isHandlingScan;
  final bool isLoadingPreview;

  FumbleState copyWith({
    FumblePreview? preview,
    bool clearPreview = false,
    bool? isConfirming,
    bool? isHandlingScan,
    bool? isLoadingPreview,
  }) {
    return FumbleState(
      preview: clearPreview ? null : (preview ?? this.preview),
      isConfirming: isConfirming ?? this.isConfirming,
      isHandlingScan: isHandlingScan ?? this.isHandlingScan,
      isLoadingPreview: isLoadingPreview ?? this.isLoadingPreview,
    );
  }
}

class FumbleNotifier extends Notifier<FumbleState> {
  NotificationService get _notifications =>
      ref.read(notificationServiceProvider);

  @override
  FumbleState build() => const FumbleState();

  void startFumble() {
    unawaited(AnalyticsService.instance.logFumbleStarted());
    push(AppRoutes.fumbleScanner);
  }

  /// Local-only QR decode for a fast scan. Firebase runs on the preview screen.
  Future<bool> resolveScan(String raw) async {
    if (state.isHandlingScan) return false;

    final decoded = FumbleQr.decode(raw);
    final payload = decoded.payload;
    if (payload == null) {
      showAppToast(_qrMessage(decoded.error), isError: true);
      return false;
    }

    final uid = ref.read(authServiceProvider).currentUser?.uid;
    if (uid == null) {
      showAppToast(AppConstant.authPleaseLogIn, isError: true);
      return false;
    }

    state = state.copyWith(isHandlingScan: true);
    try {
      final mine = ref.read(currentUserProfileProvider).valueOrNull ??
          await LocalPrefs.loadUserProfile();
      final myCode = mine?.fumbleCode.trim().toUpperCase() ?? '';
      if (myCode.isNotEmpty && myCode == payload.fumbleCode) {
        showAppToast(AppConstant.cannotFumbleSelf, isError: true);
        return false;
      }

      // Instant preview: name (+ code) only. Details load on the preview screen.
      state = state.copyWith(
        preview: FumblePreview(
          fumbleCode: payload.fumbleCode,
          name: payload.name,
        ),
      );
      unawaited(AnalyticsService.instance.logQrScanned());
      unawaited(AnalyticsService.instance.logFumblePreviewViewed());
      return true;
    } catch (e) {
      showAppToast(AppConstant.invalidQr, isError: true);
      return false;
    } finally {
      state = state.copyWith(isHandlingScan: false);
    }
  }

  /// Loads full public card after preview opens (online only).
  Future<void> loadPreviewDetails() async {
    final preview = state.preview;
    if (preview == null || preview.fumbleCode.isEmpty) return;
    if (!ConnectionManager().isConnected) return;
    if (state.isLoadingPreview) return;

    state = state.copyWith(isLoadingPreview: true);
    try {
      final card = await ref
          .read(fumbleCodeRepositoryProvider)
          .loadPublicCardByCode(preview.fumbleCode)
          .timeout(const Duration(seconds: 8));
      if (state.preview?.fumbleCode != preview.fumbleCode) return;
      if (card == null) {
        showAppToast(AppConstant.fumbleCodeNotFound, isError: true);
        return;
      }

      final uid = ref.read(authServiceProvider).currentUser?.uid;
      if (uid != null && card.uid == uid) {
        showAppToast(AppConstant.cannotFumbleSelf, isError: true);
        cancel();
        return;
      }
      if (uid != null) {
        final already = await ref
            .read(connectionRepositoryProvider)
            .hasLocalConnection(ownerUid: uid, peerUid: card.uid);
        if (already) {
          showAppToast(AppConstant.alreadyConnected, isError: true);
          cancel();
          return;
        }
      }

      state = state.copyWith(
        preview: FumblePreview(
          fumbleCode: preview.fumbleCode,
          name: card.name.isNotEmpty ? card.name : preview.name,
          peerUid: card.uid,
          email: card.shareEmail ? card.email : null,
          photoUrl: card.photoUrl,
          bio: card.bio,
          aboutMe: card.aboutMe,
          location: card.location,
          phone: card.sharePhone ? card.phone : null,
          createdAt: card.createdAt,
        ),
      );
    } catch (_) {
      // Stay on name-only preview if Firebase fails.
    } finally {
      if (state.preview?.fumbleCode == preview.fumbleCode) {
        state = state.copyWith(isLoadingPreview: false);
      }
    }
  }

  /// Saves the preview locally first. Firebase sync continues in the background.
  Future<void> confirm({String? note}) async {
    var preview = state.preview;
    if (preview == null) {
      pop();
      return;
    }
    if (state.isConfirming) return;

    final uid = ref.read(authServiceProvider).currentUser?.uid;
    if (uid == null) {
      showAppToast(AppConstant.authPleaseLogIn, isError: true);
      return;
    }

    if (!preview.isResolved && !ConnectionManager().isConnected) {
      showAppToast(AppConstant.previewNeedsNetwork, isError: true);
      return;
    }

    showLoadingDialog(message: AppConstant.loading);
    state = state.copyWith(isConfirming: true);
    try {
      if (!preview.isResolved) {
        await loadPreviewDetails();
        preview = state.preview;
        if (preview == null || !preview.isResolved) {
          hideLoadingDialog();
          state = state.copyWith(isConfirming: false);
          showAppToast(AppConstant.fumbleCodeNotFound, isError: true);
          return;
        }
      }

      final place = await FumbleLocationService.currentLocation();
      final created = await ref
          .read(connectionRepositoryProvider)
          .saveScannedConnection(
            ownerUid: uid,
            preview: preview,
            fumbleLocation: place,
            note: note,
          );
      if (!created) {
        hideLoadingDialog();
        state = state.copyWith(isConfirming: false);
        showAppToast(AppConstant.alreadyConnected, isError: true);
        return;
      }
      unawaited(AnalyticsService.instance.logFumbleConfirmed());
      unawaited(AnalyticsService.instance.logConnectionCreated());
      unawaited(_notifications.requestPermissionIfNeeded());
      hideLoadingDialog();
      state = state.copyWith(isConfirming: false);
      finish(openConnections: true);
    } catch (e) {
      hideLoadingDialog();
      state = state.copyWith(isConfirming: false);
      showAppToast(AppConstant.somethingWrong, isError: true);
    }
  }

  void cancel() {
    state = const FumbleState();
    pushAndClearAll(AppRoutes.main);
  }

  void finish({required bool openConnections}) {
    state = const FumbleState();
    if (openConnections) {
      ref.read(bottomNavProvider.notifier).setIndex(AppNavIndex.connections);
    }
    pushAndClearAll(AppRoutes.main);
  }

  String _qrMessage(QrDecodeError? error) {
    return switch (error) {
      QrDecodeError.malformed => AppConstant.malformedQr,
      QrDecodeError.unsupportedVersion => AppConstant.unsupportedQrVersion,
      QrDecodeError.missingFumbleCode => AppConstant.qrMissingFumbleCode,
      QrDecodeError.missingName => AppConstant.qrMissingName,
      QrDecodeError.invalid || null => AppConstant.invalidQr,
    };
  }
}

final fumbleNotifierProvider = NotifierProvider<FumbleNotifier, FumbleState>(
  FumbleNotifier.new,
);
