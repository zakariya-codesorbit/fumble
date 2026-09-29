import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:fumble/core/navigation/router_navigator.dart';
import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/utils/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/base/base_screen_widget.dart';
import 'package:fumble/view/widgets/buttons/primary_button.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/feedback/app_loader.dart';
import 'package:fumble/view/widgets/layout/app_app_bar.dart';
import 'package:fumble/view/widgets/navigation/back_icon_button.dart';

/// Find a Fumble — camera scanner with branded frame overlay.
class FlumbleScannerScreen extends ConsumerStatefulWidget {
  const FlumbleScannerScreen({super.key});

  @override
  ConsumerState<FlumbleScannerScreen> createState() =>
      _FlumbleScannerScreenState();
}

class _FlumbleScannerScreenState extends ConsumerState<FlumbleScannerScreen>
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
    final frameSize = MediaQuery.sizeOf(context).width * 0.78;

    return BaseScreenWidget(
      builder: (context) => ScaffoldContent(
        appBar: AppAppBar(
          title: AppConstant.connectFumble,
          brandTitle: true,
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
                      Container(
                        color: AppColors.background.withValues(alpha: 0.28),
                      ),
                      Center(
                        child: SizedBox(
                          width: frameSize,
                          height: frameSize,
                          child: CustomPaint(
                            painter: _ScanFramePainter(
                              color: AppColors.gold,
                              pulse: _detecting,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: _StatusSheet(detecting: _detecting),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _StatusSheet extends StatelessWidget {
  const _StatusSheet({required this.detecting});

  final bool detecting;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 28),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.45)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          (detecting
                  ? AppConstant.scanningMarker
                  : AppConstant.lookingForFumble)
              .toText(
            color: AppColors.gold,
            fontSize: 16,
            fontWeight: AppStyle.w600,
            textAlign: TextAlign.center,
          ),
          6.height,
          AppConstant.scannerHint.toText(
            color: AppColors.softGray,
            fontSize: 13,
            textAlign: TextAlign.center,
          ),
        ],
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

class _ScanFramePainter extends CustomPainter {
  _ScanFramePainter({required this.color, required this.pulse});

  final Color color;
  final bool pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(28),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..color = color.withValues(alpha: pulse ? 0.55 : 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = pulse ? 3.5 : 2.5,
    );

    const arm = 28.0;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    final r = Offset.zero & size;

    void corner(Offset a, Offset b, Offset c) {
      canvas.drawLine(a, b, paint);
      canvas.drawLine(b, c, paint);
    }

    corner(r.topLeft + const Offset(0, arm), r.topLeft,
        r.topLeft + const Offset(arm, 0));
    corner(r.topRight + const Offset(-arm, 0), r.topRight,
        r.topRight + const Offset(0, arm));
    corner(r.bottomLeft + const Offset(0, -arm), r.bottomLeft,
        r.bottomLeft + const Offset(arm, 0));
    corner(r.bottomRight + const Offset(-arm, 0), r.bottomRight,
        r.bottomRight + const Offset(0, -arm));
  }

  @override
  bool shouldRepaint(covariant _ScanFramePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.pulse != pulse;
  }
}
