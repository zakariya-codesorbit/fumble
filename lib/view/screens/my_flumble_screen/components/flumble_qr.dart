import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:fumble/utils/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';

class FlumbleQr extends StatelessWidget {
  const FlumbleQr({
    super.key,
    required this.payload,
    required this.code,
    this.onCopy,
  });

  final String payload;
  final String code;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppConstant.scanToFumble.toText(
          color: AppColors.gold,
          fontSize: 12,
          fontWeight: AppStyle.w600,
          letterSpacing: 1.2,
        ),
        14.height,
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppStyle.radiusMd),
            border: Border.all(color: AppColors.gold, width: 0.5),
          ),
          child: QrImageView(
            data: payload,
            version: QrVersions.auto,
            size: 120,
            backgroundColor: AppColors.white,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: AppColors.background,
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: AppColors.background,
            ),
          ),
        ),
        12.height,
        GestureDetector(
          onLongPress: onCopy,
          child: code.toText(
            color: AppColors.gold,
            fontSize: 13,
            fontWeight: AppStyle.w600,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}
