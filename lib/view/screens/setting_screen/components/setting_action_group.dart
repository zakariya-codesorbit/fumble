import 'package:flutter/material.dart';

import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';

class SettingActionGroup extends StatelessWidget {
  const SettingActionGroup({
    super.key,
    required this.title,
    required this.items,
  });

  final String title;
  final List<SettingActionItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title.toText(
          color: AppColors.gold,
          fontSize: 12,
          fontWeight: AppStyle.w600,
          letterSpacing: 1.2,
        ),
        10.height,
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppStyle.radiusLg),
            border: Border.all(color: AppColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.border,
                  ),
                _ActionRow(item: items[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class SettingActionItem {
  const SettingActionItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.foreground = AppColors.white,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color foreground;
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.item});

  final SettingActionItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.clear,
      child: InkWell(
        onTap: item.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Icon(item.icon, color: item.foreground, size: 22),
              14.width,
              Expanded(
                child: item.label.toText(
                  color: item.foreground,
                  fontSize: 16,
                  fontWeight: AppStyle.w500,
                ),
              ),
              Icon(
                AppIcons.chevronRight,
                color: item.foreground == AppColors.error
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
