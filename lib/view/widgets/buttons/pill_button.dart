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
    required this.onTap,
    this.backgroundColor = AppColors.clear,
    this.foregroundColor = AppColors.white,
    this.borderColor = AppColors.border,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
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
            border: Border.all(color: borderColor, width: 0.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18.w, color: foregroundColor),
              8.width,
              label.toText(
                color: foregroundColor,
                fontSize: 16,
                fontWeight: AppStyle.w700,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
