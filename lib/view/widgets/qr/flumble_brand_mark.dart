import 'package:flutter/material.dart';

import 'package:fumble/utils/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';

/// Circular Fumble mark: gold ring and wordmark.
class FlumbleBrandMark extends StatelessWidget {
  const FlumbleBrandMark({
    super.key,
    required this.size,
    this.filled = false,
  });

  final double size;

  /// Light plate used when the mark sits in a QR center.
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? AppColors.gold : AppColors.clear,
        border: Border.all(
          color: AppColors.gold,
          width: (size * 0.02).clamp(1.5, AppStyle.fumbleButtonStroke),
        ),
      ),
      child: AppConstant.fumbleCta.split('').join(' ').toText(
            color: AppColors.gold,
            fontSize: size * 0.12,
            fontWeight: AppStyle.w600,
            letterSpacing: size * 0.015,
            textAlign: TextAlign.center,
          ),
    );
  }
}
