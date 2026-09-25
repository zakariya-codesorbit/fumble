import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:fumble/core/navigation/app_routes.dart';
import 'package:fumble/core/navigation/router_navigator.dart';
import 'package:fumble/state/notifiers/fumble_notifier.dart';
import 'package:fumble/view/widgets/dialogs/loading_dialog.dart';

class ScannerState {
  const ScannerState({
    this.checkingPermission = true,
    this.permissionDenied = false,
  });

  final bool checkingPermission;
  final bool permissionDenied;

  ScannerState copyWith({
    bool? checkingPermission,
    bool? permissionDenied,
  }) {
    return ScannerState(
      checkingPermission: checkingPermission ?? this.checkingPermission,
      permissionDenied: permissionDenied ?? this.permissionDenied,
    );
  }
}

class ScannerNotifier extends AutoDisposeNotifier<ScannerState> {
  MobileScannerController? _controller;

  MobileScannerController get controller => _controller!;

  @override
  ScannerState build() {
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
    ref.onDispose(() {
      _controller?.dispose();
      _controller = null;
    });
    Future.microtask(requestCameraPermission);
    return const ScannerState();
  }

  Future<void> requestCameraPermission() async {
    state = state.copyWith(checkingPermission: true);
    final status = await Permission.camera.request();
    state = ScannerState(
      checkingPermission: false,
      permissionDenied: !status.isGranted,
    );
  }

  Future<bool> openSettings() => openAppSettings();

  Future<void> onDetect(BarcodeCapture capture) async {
    if (state.checkingPermission || state.permissionDenied) return;
    if (capture.barcodes.isEmpty) return;
    final raw = capture.barcodes.first.rawValue;
    if (raw == null) return;

    await controller.stop();
    showLoadingDialog();
    final success =
        await ref.read(fumbleNotifierProvider.notifier).resolveScan(raw);
    hideLoadingDialog();
    if (success) {
      replace(AppRoutes.fumblePreview);
      return;
    }
    await controller.start();
  }
}

final scannerNotifierProvider =
    NotifierProvider.autoDispose<ScannerNotifier, ScannerState>(
  ScannerNotifier.new,
);
