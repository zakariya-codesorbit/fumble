import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/core/navigation/app_nav_index.dart';
import 'package:fumble/core/navigation/app_routes.dart';
import 'package:fumble/core/navigation/router_navigator.dart';
import 'package:fumble/data/models/fumble_preview.dart';
import 'package:fumble/services/analytics/analytics_service.dart';
import 'package:fumble/services/location/fumble_location_service.dart';
import 'package:fumble/services/network/connection_manager.dart';
import 'package:fumble/state/notifiers/bottom_navigation_notifier.dart';
import 'package:fumble/state/providers/service_providers.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/view/widgets/dialogs/loading_dialog.dart';
import 'package:fumble/view/widgets/feedback/custom_snackbar.dart';
import '../../services/fumble/fumble_qr.dart';

class FumbleState {
  const FumbleState({
    this.preview,
    this.isHandlingScan = false,
    this.isLoadingPreview = false,
    this.isConnecting = false,
    this.isSavingNote = false,
    this.connectionSaved = false,
  });

  final FumblePreview? preview;
  final bool isHandlingScan;
  final bool isLoadingPreview;
  final bool isConnecting;
  final bool isSavingNote;
  final bool connectionSaved;

  FumbleState copyWith({
    FumblePreview? preview,
    bool clearPreview = false,
    bool? isHandlingScan,
    bool? isLoadingPreview,
    bool? isConnecting,
    bool? isSavingNote,
    bool? connectionSaved,
  }) {
    return FumbleState(
      preview: clearPreview ? null : (preview ?? this.preview),
      isHandlingScan: isHandlingScan ?? this.isHandlingScan,
      isLoadingPreview: isLoadingPreview ?? this.isLoadingPreview,
      isConnecting: isConnecting ?? this.isConnecting,
      isSavingNote: isSavingNote ?? this.isSavingNote,
      connectionSaved: connectionSaved ?? this.connectionSaved,
    );
  }
}

class FumbleNotifier extends Notifier<FumbleState> {
  @override
  FumbleState build() => const FumbleState();

  void startFumble() {
    unawaited(AnalyticsService.instance.logFumbleStarted());
    push(AppRoutes.fumbleScanner);
  }

  /// Local-only QR decode. Connects offline via peer uid; Firebase enriches online.
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
      if (payload.userId == uid) {
        showAppToast(AppConstant.cannotFumbleSelf, isError: true);
        return false;
      }

      final already = await ref
          .read(connectionRepositoryProvider)
          .hasLocalConnection(ownerUid: uid, peerUid: payload.userId);
      if (already) {
        showAppToast(AppConstant.alreadyConnected, isError: true);
        return false;
      }

      state = state.copyWith(
        preview: FumblePreview(
          name: payload.name,
          peerUid: payload.userId,
        ),
        connectionSaved: false,
      );
      unawaited(AnalyticsService.instance.logQrScanned());
      unawaited(AnalyticsService.instance.logFumblePreviewViewed());
      // Local save immediately (works offline). Cloud sync when online.
      unawaited(autoConnect());
      return true;
    } catch (e) {
      showAppToast(AppConstant.invalidQr, isError: true);
      return false;
    } finally {
      state = state.copyWith(isHandlingScan: false);
    }
  }

  /// Loads full public card when online (by peer uid). Connect is separate.
  Future<void> loadPreviewDetails() async {
    final preview = state.preview;
    if (preview == null || !preview.isResolved) return;
    if (!ConnectionManager().isConnected) return;
    if (state.isLoadingPreview) return;
    if (preview.enriched) {
      if (!state.connectionSaved) await autoConnect();
      return;
    }

    state = state.copyWith(isLoadingPreview: true);
    try {
      final card = await ref
          .read(fumbleCodeRepositoryProvider)
          .loadPublicProfile(preview.peerUid)
          .timeout(const Duration(seconds: 8));
      if (state.preview?.peerUid != preview.peerUid) return;
      if (card == null) {
        if (!state.connectionSaved) await autoConnect();
        return;
      }

      final uid = ref.read(authServiceProvider).currentUser?.uid;
      if (uid != null && card.uid == uid) {
        showAppToast(AppConstant.cannotFumbleSelf, isError: true);
        cancel();
        return;
      }

      final enriched = FumblePreview(
        name: card.name.isNotEmpty ? card.name : preview.name,
        peerUid: card.uid.isNotEmpty ? card.uid : preview.peerUid,
        email: card.shareEmail ? card.email : null,
        photoUrl: card.photoUrl,
        bio: card.bio,
        aboutMe: card.aboutMe,
        location: card.location,
        phone: card.sharePhone ? card.phone : null,
        createdAt: card.createdAt,
        enriched: true,
      );
      state = state.copyWith(preview: enriched);
      if (uid != null && state.connectionSaved) {
        unawaited(
          ref.read(connectionRepositoryProvider).enrichLocalConnection(
                ownerUid: uid,
                preview: enriched,
              ),
        );
      }
      if (!state.connectionSaved) await autoConnect();
    } catch (_) {
      if (!state.connectionSaved) await autoConnect();
    } finally {
      if (state.preview?.peerUid == preview.peerUid) {
        state = state.copyWith(isLoadingPreview: false);
      }
    }
  }

  /// Saves locally first (offline OK). Firebase sync runs via ConnectionSync.
  Future<void> autoConnect() async {
    final preview = state.preview;
    if (preview == null || !preview.isResolved) return;
    if (state.connectionSaved || state.isConnecting) return;

    final uid = ref.read(authServiceProvider).currentUser?.uid;
    if (uid == null) return;
    if (preview.peerUid == uid) {
      showAppToast(AppConstant.cannotFumbleSelf, isError: true);
      cancel();
      return;
    }

    state = state.copyWith(isConnecting: true);
    try {
      final place = await FumbleLocationService.currentLocation();
      final created = await ref
          .read(connectionRepositoryProvider)
          .saveScannedConnection(
            ownerUid: uid,
            preview: preview,
            fumbleLocation: place,
          );
      if (state.preview?.peerUid != preview.peerUid) return;
      if (!created) {
        showAppToast(AppConstant.alreadyConnected, isError: true);
        cancel();
        return;
      }
      unawaited(AnalyticsService.instance.logFumbleConfirmed());
      unawaited(AnalyticsService.instance.logConnectionCreated());
      state = state.copyWith(isConnecting: false, connectionSaved: true);
    } catch (_) {
      if (state.preview?.peerUid == preview.peerUid) {
        state = state.copyWith(isConnecting: false);
      }
      showAppToast(AppConstant.somethingWrong, isError: true);
    }
  }

  /// Done is only for attaching a note, then leaving.
  Future<void> saveNoteAndFinish({required String note}) async {
    final trimmed = note.trim();
    if (trimmed.isEmpty) {
      finish(openConnections: true);
      return;
    }
    if (state.isSavingNote) return;

    var preview = state.preview;
    if (preview == null) {
      finish(openConnections: true);
      return;
    }

    final uid = ref.read(authServiceProvider).currentUser?.uid;
    if (uid == null) {
      showAppToast(AppConstant.authPleaseLogIn, isError: true);
      return;
    }

    showLoadingDialog(message: AppConstant.loading);
    state = state.copyWith(isSavingNote: true);
    try {
      if (!state.connectionSaved) {
        await autoConnect();
        preview = state.preview;
        if (preview == null ||
            !preview.isResolved ||
            !state.connectionSaved) {
          hideLoadingDialog();
          state = state.copyWith(isSavingNote: false);
          showAppToast(AppConstant.somethingWrong, isError: true);
          return;
        }
      }

      await ref.read(connectionRepositoryProvider).updateConnectionNote(
            ownerUid: uid,
            peerUid: preview.peerUid,
            note: trimmed,
          );
      hideLoadingDialog();
      state = state.copyWith(isSavingNote: false);
      finish(openConnections: true);
    } catch (_) {
      hideLoadingDialog();
      state = state.copyWith(isSavingNote: false);
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
      QrDecodeError.missingUserId => AppConstant.qrMissingUserId,
      QrDecodeError.missingName => AppConstant.qrMissingName,
      QrDecodeError.invalid || null => AppConstant.invalidQr,
    };
  }
}

final fumbleNotifierProvider = NotifierProvider<FumbleNotifier, FumbleState>(
  FumbleNotifier.new,
);
