import 'package:flutter/material.dart';

import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';

class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final bg = filled
        ? (enabled ? AppColors.gold : AppColors.border)
        : AppColors.surfaceElevated;
    final fg = filled
        ? AppColors.background
        : (enabled ? AppColors.white : AppColors.softGrayDim);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppStyle.radiusPill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppStyle.radiusPill),
        child: Container(
          height: 38.h,
          width: 85.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppStyle.radiusPill),
            border: filled
                ? null
                : Border.all(
                    color: enabled ? AppColors.border : AppColors.softGrayDim,
                  ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18.w, color: fg),
              8.width,
              label.toText(color: fg, fontSize: 16, fontWeight: AppStyle.w700),
            ],
          ),
        ),
      ),
    );
  }
}
