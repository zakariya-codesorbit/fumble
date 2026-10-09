import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/core/navigation/app_nav_index.dart';
import 'package:fumble/core/navigation/app_routes.dart';
import 'package:fumble/core/navigation/router_navigator.dart';
import 'package:fumble/data/models/fumble_preview.dart';
import 'package:fumble/services/analytics/analytics_service.dart';
import 'package:fumble/services/location/fumble_location_service.dart';
import 'package:fumble/services/network/connection_manager.dart';
import 'package:fumble/services/notifications/notification_service.dart';
import 'package:fumble/state/notifiers/bottom_navigation_notifier.dart';
import 'package:fumble/state/providers/service_providers.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/view/widgets/feedback/custom_snackbar.dart';
import '../../services/fumble/fumble_qr.dart';

class FumbleState {
  const FumbleState({
    this.preview,
    this.isConfirming = false,
    this.isHandlingScan = false,
  });

  final FumblePreview? preview;
  final bool isConfirming;
  final bool isHandlingScan;

  FumbleState copyWith({
    FumblePreview? preview,
    bool clearPreview = false,
    bool? isConfirming,
    bool? isHandlingScan,
  }) {
    return FumbleState(
      preview: clearPreview ? null : (preview ?? this.preview),
      isConfirming: isConfirming ?? this.isConfirming,
      isHandlingScan: isHandlingScan ?? this.isHandlingScan,
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

  /// Decodes and validates a QR locally. Does not create a connection.
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
    if (payload.userId == uid) {
      showAppToast(AppConstant.cannotFumbleSelf, isError: true);
      return false;
    }

    state = state.copyWith(isHandlingScan: true);
    try {
      final already = await ref
          .read(connectionRepositoryProvider)
          .hasLocalConnection(ownerUid: uid, peerUid: payload.userId);
      if (already) {
        showAppToast(AppConstant.alreadyConnected, isError: true);
        return false;
      }

      // Start from QR fields only. Enrich from Firebase when online, with a
      // short timeout so a slow network cannot block the scanner.
      final online = ConnectionManager().isConnected;
      var preview = FumblePreview(
        peerUid: payload.userId,
        name: payload.name,
        phone: payload.phone,
        email: payload.email,
        bio: online ? payload.bio : null,
        createdAt: online ? payload.createdAt : null,
      );

      if (online) {
        try {
          final card = await ref
              .read(fumbleCodeRepositoryProvider)
              .loadPublicProfile(payload.userId)
              .timeout(const Duration(seconds: 4));
          if (card != null) {
            preview = FumblePreview(
              peerUid: payload.userId,
              name: card.name.isNotEmpty ? card.name : payload.name,
              email: card.shareEmail
                  ? (card.email.isNotEmpty ? card.email : payload.email)
                  : null,
              photoUrl: card.photoUrl,
              bio: card.bio ?? payload.bio,
              aboutMe: card.aboutMe,
              location: card.location,
              phone: card.sharePhone ? (card.phone ?? payload.phone) : null,
              createdAt: card.createdAt ?? payload.createdAt,
            );
          }
        } catch (_) {
          // Keep QR-only preview if Firebase is slow or unavailable.
        }
      }

      state = state.copyWith(preview: preview);
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

  /// Saves the preview locally first. Firebase sync continues in the background.
  Future<void> confirm({String? note}) async {
    final preview = state.preview;
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

    state = state.copyWith(isConfirming: true);
    try {
      // Scanner location if permission is on; peer location is used as fallback
      // inside saveScannedConnection when this is null.
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
        state = state.copyWith(isConfirming: false);
        showAppToast(AppConstant.alreadyConnected, isError: true);
        return;
      }
      unawaited(AnalyticsService.instance.logFumbleConfirmed());
      unawaited(AnalyticsService.instance.logConnectionCreated());
      unawaited(_notifications.requestPermissionIfNeeded());
      state = state.copyWith(isConfirming: false);
      finish(openConnections: true);
    } catch (e) {
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
      QrDecodeError.missingUserId => AppConstant.qrMissingUserId,
      QrDecodeError.missingName => AppConstant.qrMissingName,
      QrDecodeError.invalid || null => AppConstant.invalidQr,
    };
  }
}

final fumbleNotifierProvider = NotifierProvider<FumbleNotifier, FumbleState>(
  FumbleNotifier.new,
);
