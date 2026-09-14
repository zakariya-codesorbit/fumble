import 'package:flutter/material.dart';

import 'package:fumble/utils/colors.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';

class TextButtonWidget extends StatelessWidget {
  const TextButtonWidget({
    super.key,
    required this.buttonName,
    required this.onPressed,
    this.color,
    this.fontSize = 14,
    this.fontWeight,
  });

  final String buttonName;
  final VoidCallback? onPressed;
  final Color? color;
  final double fontSize;
  final FontWeight? fontWeight;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: buttonName.toText(
        color: color ?? AppColors.gold,
        fontSize: fontSize,
        fontWeight: fontWeight ?? AppStyle.w400,
      ),
    );
  }
}
