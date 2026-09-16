import 'package:flutter/material.dart';

import 'package:fumble/utils/colors.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/extention/border_extension.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';

/// Shared primary action button (gold filled by default).
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.buttonName,
    required this.onPressed,
    this.isLoading = false,
    this.filled = true,
    this.buttonColor,
    this.borderColor,
    this.buttonTextColor,
    this.width,
    this.height,
    this.radius = AppStyle.radiusPill,
    this.textSize = 16,
    this.fontWeight = AppStyle.w700,
  });

  final String buttonName;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool filled;
  final Color? buttonColor;
  final Color? borderColor;
  final Color? buttonTextColor;
  final double? width;
  final double? height;
  final double radius;
  final double textSize;
  final FontWeight fontWeight;

  bool get _enabled => onPressed != null && !isLoading;

  double get _effectiveWidth => width ?? double.infinity;

  double get _effectiveHeight => height ?? 52.h;

  @override
  Widget build(BuildContext context) {
    final bg = buttonColor ?? (filled ? AppColors.gold : AppColors.clear);
    final border = borderColor ??
        (filled ? (buttonColor ?? AppColors.gold) : AppColors.border);
    final fg = buttonTextColor ??
        (filled ? AppColors.background : AppColors.white);
    final br = borderRadiusCircular(radius);

    return SizedBox(
      width: _effectiveWidth,
      height: _effectiveHeight,
      child: ElevatedButton(
        onPressed: _enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: filled || buttonColor != null
              ? bg
              : AppColors.white.withValues(alpha: 0.06),
          foregroundColor: fg,
          disabledBackgroundColor: AppColors.goldMuted,
          elevation: 0,
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(borderRadius: br),
        ),
        child: isLoading
            ? SizedBox(
                width: 22.h,
                height: 22.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: fg,
                ),
              )
            : buttonName.toText(
                color: fg,
                fontSize: textSize,
                fontWeight: fontWeight,
              ),
      ),
    );
  }
}
