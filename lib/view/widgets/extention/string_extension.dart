import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:fumble/utils/colors.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';

extension StringExtension on String {
  /// Brand / splash-style text with explicit typography.
  Widget toBrandText({
    required Color color,
    required double fontSize,
    required FontWeight fontWeight,
    required double lineHeight,
    required TextAlign textAlign,
    required double letterSpacing,
    required TextOverflow overflow,
    String? fontFamily,
    int? maxLine,
  }) {
    return toText(
      color: color,
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      lineHeight: lineHeight,
      textAlign: textAlign,
      letterSpacing: letterSpacing,
      overflow: overflow,
      maxLine: maxLine,
    );
  }

  Widget toText({
    Color? color,
    double? fontSize,
    int? maxLine,
    TextAlign? textAlign,
    TextOverflow? overflow,
    String? fontFamily,
    FontWeight? fontWeight,
    Color? backgroundColor,
    double? lineHeight,
    double? letterSpacing,
    bool? isBold,
    bool? isMedium,
  }) {
    final fs = (fontSize ?? 12).toInt().h;
    return Text(
      this,
      maxLines: maxLine,
      textAlign: textAlign,
      overflow: overflow ?? (maxLine != null ? TextOverflow.ellipsis : null),
      softWrap: true,
      style: TextStyle(
        height: lineHeight,
        backgroundColor: backgroundColor,
        color: color ?? AppColors.white,
        fontSize: fs,
        fontFamily: fontFamily,
        fontFamilyFallback: AppStyle.fontFamilyFallback,
        fontStyle: FontStyle.normal,
        letterSpacing: letterSpacing,
        fontWeight: fontWeight ??
            (isBold == true
                ? FontWeight.bold
                : (isMedium == true ? AppStyle.w500 : AppStyle.w400)),
      ),
    );
  }

  bool get isBlank => trim().isEmpty;

  bool get isNotBlank => !isBlank;

  bool get isValidEmail => contains('@');
}

extension CapitalizeExtension on String {
  String capitalize() {
    if (trim().isEmpty) return this;
    return trim().characters.first.toUpperCase() +
        trim().characters.skip(1).toString();
  }
}

extension NumberFormatExtension on int {
  String toNumberFormat() {
    return NumberFormat('#,##0').format(this);
  }
}
