import 'package:flutter/material.dart';

import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';

/// Segmented On Off toggle in a rounded rectangular capsule.
class CustomToggle extends StatelessWidget {
  const CustomToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.onLabel = 'On',
    this.offLabel = 'Off',
    this.height = 18,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String onLabel;
  final String offLabel;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(color: AppColors.warmGray, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Segment(
            label: onLabel,
            selected: value,
            height: height,
            onTap: () => onChanged(true),
            isLeading: true,
          ),
          _Segment(
            label: offLabel,
            selected: !value,
            height: height,
            onTap: () => onChanged(false),
            isLeading: false,
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.height,
    required this.onTap,
    required this.isLeading,
  });

  final String label;
  final bool selected;
  final double height;
  final VoidCallback onTap;
  final bool isLeading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.gold : AppColors.clear,
          borderRadius: BorderRadius.horizontal(
            left: isLeading ? Radius.circular(height / 2) : Radius.zero,
            right: !isLeading ? Radius.circular(height / 2) : Radius.zero,
          ),
        ),
        child: label.toText(
          fontSize: 9,
          fontWeight: AppStyle.w600,
          color: selected ? AppColors.background : AppColors.warmGray,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
