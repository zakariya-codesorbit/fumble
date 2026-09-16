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
import 'package:fumble/view/widgets/buttons/secondary_button.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/extention/widget_extension.dart';
import 'package:fumble/view/widgets/feedback/app_loader.dart';
import 'package:fumble/view/widgets/layout/app_app_bar.dart';
import 'package:fumble/view/widgets/navigation/back_icon_button.dart';
import 'package:fumble/view/widgets/qr/flumble_scan_overlay.dart';

class QrScannerScreen extends ConsumerWidget {
  const QrScannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanner = ref.watch(scannerNotifierProvider);
    final scannerActions = ref.read(scannerNotifierProvider.notifier);

    return BaseScreenWidget(
      builder: (context) => ScaffoldContent(
        appBar: AppAppBar(
          title: AppConstant.scannerTitle,
          brandTitle: true,
          leading: BackIconButton(icon: AppIcons.close, onTap: pop),
        ),
        body: scanner.checkingPermission
            ? const AppLoader()
            : scanner.permissionDenied
                ? _PermissionDenied(
                    onRetry: scannerActions.requestCameraPermission,
                    onOpenSettings: () {
                      scannerActions.openSettings();
                    },
                  )
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      MobileScanner(
                        controller: scannerActions.controller,
                        onDetect: scannerActions.onDetect,
                      ),
                      const IgnorePointer(child: FlumbleScanOverlay()),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                          child: AppConstant.scannerHint.toText(
                            textAlign: TextAlign.center,
                            fontSize: 14,
                            color: AppColors.softGray,
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _PermissionDenied extends StatelessWidget {
  const _PermissionDenied({
    required this.onRetry,
    required this.onOpenSettings,
  });
  final VoidCallback onRetry;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          AppIcons.camera,
          color: AppColors.softGray,
          size: 48,
        ),
        16.height,
        AppConstant.cameraPermissionDenied.toText(
          textAlign: TextAlign.center,
          fontSize: 16,
        ),
        24.height,
        PrimaryButton(buttonName: AppConstant.retry, onPressed: onRetry),
        12.height,
        SecondaryButton(
          buttonName: AppConstant.openSettings,
          onPressed: onOpenSettings,
        ),
      ],
    ).paddingAll(24);
  }
}
