import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:fumble/core/navigation/router_navigator.dart';
import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/utils/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/view/widgets/base/base_screen_widget.dart';
import 'package:fumble/view/widgets/buttons/primary_button.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/feedback/app_loader.dart';
import 'package:fumble/view/widgets/layout/app_app_bar.dart';
import 'package:fumble/view/widgets/navigation/back_icon_button.dart';

/// Find a Fumble — circular scanner matching the share QR shape.
class FumbleScannerScreen extends ConsumerStatefulWidget {
  const FumbleScannerScreen({super.key});

  @override
  ConsumerState<FumbleScannerScreen> createState() =>
      _FumbleScannerScreenState();
}

class _FumbleScannerScreenState extends ConsumerState<FumbleScannerScreen>
    with WidgetsBindingObserver {
  var _detecting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(scannerNotifierProvider.notifier).refreshCameraPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scanner = ref.watch(scannerNotifierProvider);
    final actions = ref.read(scannerNotifierProvider.notifier);
    final cutout = MediaQuery.sizeOf(context).width * 0.72;

    return BaseScreenWidget(
      builder: (context) => ScaffoldContent(
        appBar: AppAppBar(
          leading: BackIconButton(icon: AppIcons.close, onTap: pop),
        ),
        body: scanner.checkingPermission
            ? const AppLoader()
            : scanner.permissionDenied
            ? _Denied(
                onOpenSettings: actions.openSettings,
                onRetry: actions.requestCameraPermission,
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  MobileScanner(
                    controller: actions.controller,
                    onDetect: (capture) async {
                      if (_detecting || capture.barcodes.isEmpty) return;
                      setState(() => _detecting = true);
                      await actions.onDetect(capture);
                      if (mounted) setState(() => _detecting = false);
                    },
                  ),
                  CustomPaint(
                    painter: _CircularScanOverlayPainter(
                      cutoutSize: cutout,
                      pulse: _detecting,
                    ),
                    child: const SizedBox.expand(),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(32, 0, 32, 48),
                      child: AppConstant.scannerHint.toText(
                        color: AppColors.softGray,
                        fontSize: 15,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _Denied extends StatelessWidget {
  const _Denied({required this.onOpenSettings, required this.onRetry});

  final Future<bool> Function() onOpenSettings;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppConstant.cameraPermissionSettings.toText(
            color: AppColors.softGray,
            fontSize: 15,
            textAlign: TextAlign.center,
          ),
          24.height,
          PrimaryButton(
            buttonName: AppConstant.openSettings,
            onPressed: () => onOpenSettings(),
          ),
          12.height,
          TextButton(
            onPressed: onRetry,
            child: AppConstant.retry.toText(color: AppColors.gold),
          ),
        ],
      ),
    );
  }
}

/// Dimmed mask with a circular gold cutout matching the share QR.
class _CircularScanOverlayPainter extends CustomPainter {
  _CircularScanOverlayPainter({required this.cutoutSize, required this.pulse});

  final double cutoutSize;
  final bool pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = cutoutSize / 2;

    final hole = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    canvas.drawPath(
      hole,
      Paint()..color = AppColors.background.withValues(alpha: 0.72),
    );

    // Soft outer glow ring.
    canvas.drawCircle(
      center,
      radius + 10,
      Paint()
        ..color = AppColors.gold.withValues(alpha: pulse ? 0.18 : 0.10)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10,
    );

    // Main circular frame (matches QR plate).
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.gold.withValues(alpha: pulse ? 0.95 : 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = pulse ? 3.5 : 2.8,
    );

    // Inner guide ring.
    canvas.drawCircle(
      center,
      radius - 10,
      Paint()
        ..color = AppColors.gold.withValues(alpha: 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularScanOverlayPainter oldDelegate) {
    return oldDelegate.cutoutSize != cutoutSize || oldDelegate.pulse != pulse;
  }
}
