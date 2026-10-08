import 'package:flutter/material.dart';

import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/qr/fumble_qr_code.dart';

class FumbleQr extends StatelessWidget {
  const FumbleQr({
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
        18.height,
        Container(
          padding: const EdgeInsets.all(3),
          decoration: const BoxDecoration(
            color: AppColors.gold,
            shape: BoxShape.circle,
          ),
          child: FumbleQrCode(data: payload, size: AppStyle.fumbleQrSize),
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
