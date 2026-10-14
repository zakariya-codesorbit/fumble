import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/view/screens/fumble_screen/components/fumble_scanner_actions.dart';
import 'package:fumble/view/widgets/base/base_screen_widget.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/feedback/app_loader.dart';
import 'package:fumble/view/widgets/layout/app_app_bar.dart';
import 'package:fumble/view/widgets/navigation/back_icon_button.dart';
import 'components/scan_circular_overly.dart';
import 'components/scan_denied_view.dart';

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
      FumbleScannerActions.refreshCameraPermission(ref);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scanner = ref.watch(scannerNotifierProvider);
    final controller = ref.read(scannerNotifierProvider.notifier).controller;
    final cutout = MediaQuery.sizeOf(context).width * 0.72;

    return BaseScreenWidget(
      builder: (context) => ScaffoldContent(
        appBar: AppAppBar(
          leading: BackIconButton(
            icon: AppIcons.close,
            onTap: FumbleScannerActions.close,
          ),
        ),
        body: scanner.checkingPermission
            ? const AppLoader()
            : scanner.permissionDenied
            ? ScanDeniedView(
                onOpenSettings: () => FumbleScannerActions.openSettings(ref),
                onRetry: () =>
                    FumbleScannerActions.requestCameraPermission(ref),
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  MobileScanner(
                    controller: controller,
                    onDetect: (capture) async {
                      if (_detecting || capture.barcodes.isEmpty) return;
                      setState(() => _detecting = true);
                      await FumbleScannerActions.onDetect(
                        ref: ref,
                        capture: capture,
                      );
                      if (mounted) setState(() => _detecting = false);
                    },
                  ),
                  CustomPaint(
                    painter: CircularScanOverlayPainter(
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
