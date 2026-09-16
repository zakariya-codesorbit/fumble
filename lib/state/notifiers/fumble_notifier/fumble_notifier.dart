import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/core/navigation/app_nav_index.dart';
import 'package:fumble/core/navigation/app_routes.dart';
import 'package:fumble/core/navigation/router_navigator.dart';
import 'package:fumble/data/models/fumble_preview.dart';
import 'package:fumble/services/analytics/analytics_service.dart';
import 'package:fumble/services/fumble/fumble_service.dart';
import 'package:fumble/services/notifications/notification_service.dart';
import 'package:fumble/state/notifiers/main_notifier/bottom_navigation_notifier.dart';
import 'package:fumble/state/providers/service_providers.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/view/widgets/dialogs/loading_dialog.dart';
import 'package:fumble/view/widgets/feedback/custom_snackbar.dart';

class FumbleState {
  const FumbleState({
    this.preview,
    this.confirming = false,
    this.handlingScan = false,
  });

  final FumblePreview? preview;
  final bool confirming;
  final bool handlingScan;

  FumbleState copyWith({
    FumblePreview? preview,
    bool clearPreview = false,
    bool? confirming,
    bool? handlingScan,
  }) {
    return FumbleState(
      preview: clearPreview ? null : (preview ?? this.preview),
      confirming: confirming ?? this.confirming,
      handlingScan: handlingScan ?? this.handlingScan,
    );
  }
}

class FumbleNotifier extends Notifier<FumbleState> {
  FumbleService get _fumble => ref.read(fumbleServiceProvider);

  NotificationService get _notifications =>
      ref.read(notificationServiceProvider);

  @override
  FumbleState build() => const FumbleState();

  Future<void> startFumble() async {
    await AnalyticsService.instance.logFumbleStarted();
    await AnalyticsService.instance.logQrScannerOpened();
    push(AppRoutes.qrScanner);
  }

  Future<bool> resolveScan(String raw) async {
    if (state.handlingScan) return false;

    final code = _fumble.parseQrPayload(raw);
    if (code == null) {
      showAppToast(AppConstant.invalidQr, isError: true);
      return false;
    }

    state = state.copyWith(handlingScan: true);
    try {
      final preview = await _fumble.resolveFumble(code);
      state = state.copyWith(preview: preview, handlingScan: false);
      return true;
    } catch (e) {
      state = state.copyWith(handlingScan: false);
      showAppToast(e.toString(), isError: true);
      return false;
    }
  }

  Future<void> confirm() async {
    final preview = state.preview;
    if (preview == null) {
      pop();
      return;
    }
    if (state.confirming) return;

    showLoadingDialog(message: AppConstant.loading);
    state = state.copyWith(confirming: true);
    try {
      await _fumble.completeFumble(preview);
      await _notifications.requestPermissionIfNeeded();
      hideLoadingDialog();
      state = state.copyWith(confirming: false);
      replace(AppRoutes.fumbleSuccess);
    } catch (e) {
      hideLoadingDialog();
      state = state.copyWith(confirming: false);
      showAppToast(e.toString(), isError: true);
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
}

final fumbleNotifierProvider =
    NotifierProvider<FumbleNotifier, FumbleState>(FumbleNotifier.new);
