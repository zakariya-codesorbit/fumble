import 'package:flutter/material.dart';
import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/view/widgets/buttons/primary_button.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';

class ScanDeniedView extends StatelessWidget {
  const ScanDeniedView({required this.onOpenSettings, required this.onRetry});

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
