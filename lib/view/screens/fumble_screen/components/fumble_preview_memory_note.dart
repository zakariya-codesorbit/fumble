import 'package:flutter/material.dart';

import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';

/// Multiline memory note field matching the preview design.
class FumblePreviewMemoryNote extends StatelessWidget {
  const FumblePreviewMemoryNote({
    super.key,
    required this.controller,
    this.enabled = true,
    this.onChanged,
  });

  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 120),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.navBar,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        maxLines: null,
        minLines: 4,
        cursorColor: AppColors.gold,
        onChanged: onChanged,
        style: TextStyle(
          fontSize: 14,
          height: 1.4,
          color: AppColors.secondaryText,
          fontFamily: AppStyle.fontFamily,
          fontFamilyFallback: AppStyle.fontFamilyFallback,
        ),
        decoration: InputDecoration(
          isDense: true,
          filled: false,
          hintText: AppConstant.typeMemoryHint,
          hintStyle: TextStyle(
            fontSize: 14,
            height: 1.4,
            color: AppColors.secondaryText,
            fontFamily: AppStyle.fontFamily,
            fontFamilyFallback: AppStyle.fontFamilyFallback,
          ),
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}
