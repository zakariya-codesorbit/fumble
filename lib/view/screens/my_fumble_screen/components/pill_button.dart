import 'package:flutter/material.dart';

import '../../../../utils/colors.dart';
import '../../../../utils/style.dart';
import '../../../widgets/extention/int_extension.dart';
import '../../../widgets/extention/string_extension.dart';

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
        ? (enabled
              ? AppColors.gold
              : AppColors.goldMuted.withValues(alpha: 0.4))
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
          height: 42,
          width: 90,
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
              Icon(icon, size: 18, color: fg),
              8.width,
              label.toText(color: fg, fontSize: 16, fontWeight: AppStyle.w700),
            ],
          ),
        ),
      ),
    );
  }
}
