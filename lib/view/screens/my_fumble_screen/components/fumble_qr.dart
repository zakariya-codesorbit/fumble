import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';

/// My Fumble profile QR — square white plate, gold modules (matches design).
class FumbleQr extends StatelessWidget {
  const FumbleQr({
    super.key,
    required this.payload,
    required this.code,
    this.onCopy,
    this.size = 200,
  });

  final String payload;
  final String code;
  final VoidCallback? onCopy;
  final double size;

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
        16.height,
        Container(
          width: size,
          height: size,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: PrettyQrView.data(
            data: payload,
            errorCorrectLevel: QrErrorCorrectLevel.M,
            decoration: const PrettyQrDecoration(
              background: AppColors.white,
              shape: PrettyQrSmoothSymbol(
                color: AppColors.gold,
                roundFactor: 0,
              ),
              quietZone: PrettyQrQuietZone.zero,
            ),
          ),
        ),
        14.height,
        GestureDetector(
          onLongPress: onCopy,
          child: code.toText(
            color: AppColors.softGray,
            fontSize: 13,
            fontWeight: AppStyle.w500,
            letterSpacing: 1.6,
          ),
        ),
      ],
    );
  }
}
