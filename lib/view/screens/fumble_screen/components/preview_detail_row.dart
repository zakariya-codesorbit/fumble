import 'package:flutter/material.dart';

import 'package:fumble/utils/colors.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';

class PreviewDetailRow extends StatelessWidget {
  const PreviewDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
  });

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label.toText(
          color: AppColors.gold,
          fontSize: 12,
          fontWeight: AppStyle.w600,
          letterSpacing: 1.2,
        ),
        8.height,
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: AppColors.softGray),
              10.width,
            ],
            Expanded(
              child: value.toText(
                fontSize: 16,
                fontWeight: AppStyle.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
