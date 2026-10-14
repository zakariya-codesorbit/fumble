import 'package:flutter/material.dart';

import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';

/// Inline note [TextField] used inside [ProfileInfoCard] on preview / detail.
class ProfileNoteEditor extends StatelessWidget {
  const ProfileNoteEditor({
    super.key,
    required this.controller,
    this.enabled = true,
    this.maxLines = 4,
    this.hintText = AppConstant.addNote,
    this.onChanged,
  });

  final TextEditingController controller;
  final bool enabled;
  final int maxLines;
  final String hintText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
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
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 14,
          height: 1.4,
          color: AppColors.softGrayDim,
          fontFamily: AppStyle.fontFamily,
          fontFamilyFallback: AppStyle.fontFamilyFallback,
        ),
        contentPadding: EdgeInsets.zero,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
    );
  }
}
