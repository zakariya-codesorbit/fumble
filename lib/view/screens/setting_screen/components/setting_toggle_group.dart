import 'package:flutter/material.dart';

import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/inputs/custom_toggle.dart';

class SettingToggleGroup extends StatelessWidget {
  const SettingToggleGroup({
    super.key,
    required this.title,
    required this.items,
  });

  final String title;
  final List<SettingToggleItem> items;

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
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.border,
                  ),
                _ToggleRow(item: items[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class SettingToggleItem {
  const SettingToggleItem({
    required this.label,
    required this.value,
    required this.onChanged,
    this.icon,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData? icon;
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({required this.item});

  final SettingToggleItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          if (item.icon != null) ...[
            Icon(item.icon, color: AppColors.white, size: 22),
            14.width,
          ],
          Expanded(
            child: item.label.toText(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: AppStyle.w500,
            ),
          ),
          CustomToggle(
            value: item.value,
            onChanged: item.onChanged,
            height: 22,
          ),
        ],
      ),
    );
  }
}
