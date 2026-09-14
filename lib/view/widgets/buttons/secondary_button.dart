import 'package:flutter/material.dart';

import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/buttons/primary_button.dart';

/// Outlined / muted action button — same size and radius as [PrimaryButton].
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.buttonName,
    required this.onPressed,
    this.isLoading = false,
    this.buttonColor,
    this.borderColor,
    this.buttonTextColor,
    this.fontWeight = AppStyle.w700,
  });

  final String buttonName;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? buttonColor;
  final Color? borderColor;
  final Color? buttonTextColor;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      buttonName: buttonName,
      onPressed: onPressed,
      isLoading: isLoading,
      filled: false,
      buttonColor: buttonColor,
      borderColor: borderColor,
      buttonTextColor: buttonTextColor,
      fontWeight: fontWeight,
    );
  }
}
