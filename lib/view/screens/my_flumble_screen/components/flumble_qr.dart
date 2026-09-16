import 'package:flutter/material.dart';

import 'package:fumble/utils/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/qr/flumble_qr_view.dart';

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
    final radius = AppStyle.flumbleQrSize * AppStyle.flumbleQrRadiusFactor;

    return Column(
      children: [
        AppConstant.scanToFumble.toText(
          color: AppColors.gold,
          fontSize: 12,
          fontWeight: AppStyle.w600,
          letterSpacing: 1.2,
        ),
        18.height,
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.gold, AppColors.goldDeep, AppColors.gold],
            ),
            borderRadius: BorderRadius.circular(radius + 3),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.18),
                blurRadius: 18,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: FlumbleQrView(
              data: payload,
              size: AppStyle.flumbleQrSize,
            ),
          ),
        ),
        16.height,
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
