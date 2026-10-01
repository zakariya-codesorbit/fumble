import 'package:flutter/material.dart';

import 'package:fumble/utils/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import '../../../widgets/qr/fumble_brand_mark.dart';

class FumbleButton extends StatelessWidget {
  const FumbleButton({
    super.key,
    required this.onPressed,
    this.size = AppStyle.fumbleButtonSize,
  });

  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
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
          child: FumbleBrandMark(size: size),
        ),
      ),
    );
  }
}
