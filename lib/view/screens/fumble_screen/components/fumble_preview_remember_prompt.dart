import 'package:flutter/material.dart';

import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';

/// Gold prompt under THE MOMENT: "You Fumbled X just now..."
class FumblePreviewRememberPrompt extends StatelessWidget {
  const FumblePreviewRememberPrompt({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.navBar,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: message.toText(
        color: AppColors.gold,
        fontSize: 14,
        fontWeight: AppStyle.w500,
        textAlign: TextAlign.center,
        lineHeight: 1.35,
        maxLine: 3,
      ),
    );
  }
}
