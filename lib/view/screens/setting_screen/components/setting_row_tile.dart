import 'package:flutter/material.dart';

import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/utils/colors.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';

class SettingRowTile extends StatelessWidget {
  const SettingRowTile({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.foreground = AppColors.white,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppStyle.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppStyle.radiusLg),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppStyle.radiusLg),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, color: foreground, size: 22),
              14.width,
              Expanded(
                child: label.toText(
                  color: foreground,
                  fontSize: 16,
                  fontWeight: AppStyle.w500,
                ),
              ),
              Icon(
                AppIcons.chevronRight,
                color: foreground == AppColors.error
                    ? AppColors.error.withValues(alpha: 0.7)
                    : AppColors.softGray,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
