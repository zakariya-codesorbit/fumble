import 'package:flutter/material.dart';

import 'package:fumble/core/theme/colors.dart';
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
    final enabledBg = buttonColor ?? (filled ? AppColors.primary : AppColors.clear);
    final enabledBorder = borderColor ??
        (filled ? (buttonColor ?? AppColors.primary) : AppColors.border);
    final enabledFg =
        buttonTextColor ?? (filled ? AppColors.onPrimary : AppColors.textPrimary);
    final disabledBg = AppColors.surfaceElevated;
    final disabledFg = AppColors.textDisabled;
    final disabledBorder = AppColors.border;
    final br = borderRadiusCircular(radius);
    final fg = _enabled ? enabledFg : disabledFg;

    return SizedBox(
      width: _effectiveWidth,
      height: _effectiveHeight,
      child: ElevatedButton(
        onPressed: _enabled ? onPressed : null,
        style: ButtonStyle(
          elevation: const WidgetStatePropertyAll(0),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return disabledBg;
            if (filled || buttonColor != null) return enabledBg;
            return AppColors.textPrimary.withValues(alpha: 0.06);
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return disabledFg;
            return enabledFg;
          }),
          side: WidgetStateProperty.resolveWith((states) {
            final color = states.contains(WidgetState.disabled)
                ? disabledBorder
                : enabledBorder;
            return BorderSide(color: color);
          }),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: br),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 22.h,
                height: 22.h,
                child: CircularProgressIndicator(strokeWidth: 2, color: fg),
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
