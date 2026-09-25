import 'package:flutter/material.dart';

import 'package:fumble/utils/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/qr/flumble_brand_mark.dart';
import 'package:fumble/view/widgets/qr/flumble_qr_code.dart';

class FumbleButton extends StatelessWidget {
  const FumbleButton({
    super.key,
    required this.onPressed,
    this.qrData,
    this.size = AppStyle.fumbleButtonSize,
  });

  final VoidCallback? onPressed;
  final String? qrData;
  final double size;

  @override
  Widget build(BuildContext context) {
    final data = qrData;

    return Semantics(
      button: true,
      label: AppConstant.fumbleCta,
      child: Material(
        color: AppColors.clear,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          splashColor: AppColors.gold.withValues(alpha: 0.12),
          highlightColor: AppColors.gold.withValues(alpha: 0.06),
          child: data == null
              ? FlumbleBrandMark(size: size)
              : Container(
                  width: size,
                  height: size,
                  alignment: Alignment.center,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.gold,
                    border: Border.all(
                      color: AppColors.gold,
                      width: AppStyle.fumbleButtonStroke,
                    ),
                  ),
                  child: FlumbleQrCode(data: data, size: size * 0.9),
                ),
        ),
      ),
    );
  }
}
