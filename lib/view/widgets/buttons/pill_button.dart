import 'package:flutter/material.dart';

import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';

class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.iconAsset,
    this.backgroundColor = AppColors.clear,
    this.foregroundColor = AppColors.white,
    this.borderColor = AppColors.border,
  }) : assert(icon != null || iconAsset != null);

  final String label;
  final IconData? icon;
  final String? iconAsset;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final asset = iconAsset;
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(AppStyle.radiusPill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppStyle.radiusPill),
        child: Container(
          height: 38.h,
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppStyle.radiusPill),
            border: Border.all(color: borderColor, width: 0.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (asset != null)
                Image.asset(
                  asset,
                  width: 16.w,
                  height: 16.w,
                  color: foregroundColor,
                )
              else
                Icon(icon, size: 16.w, color: foregroundColor),
              4.width,
              Flexible(
                child: label.toText(
                  color: foregroundColor,
                  fontSize: 13,
                  fontWeight: AppStyle.w700,
                  maxLine: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
