import 'package:flutter/material.dart';

import 'package:fumble/utils/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';

class FumbleButton extends StatelessWidget {
  const FumbleButton({
    super.key,
    required this.onPressed,
    this.label,
    this.size = AppStyle.fumbleButtonSize,
  });

  final VoidCallback? onPressed;
  final String? label;
  final double size;

  String get _label => label ?? AppConstant.fumbleCta;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: _label,
      child: Material(
        color: AppColors.clear,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          splashColor: AppColors.gold.withValues(alpha: 0.12),
          highlightColor: AppColors.gold.withValues(alpha: 0.06),
          child: Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.gold,
                width: AppStyle.fumbleButtonStroke,
              ),
            ),
            child: _label.split('').join(' ').toText(
              color: AppColors.gold,
              fontSize: 32,
              fontWeight: AppStyle.w600,
              letterSpacing: 4,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
