import 'package:flutter/material.dart';

import 'package:fumble/utils/colors.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';

class ProfileInfoCard extends StatelessWidget {
  const ProfileInfoCard({
    super.key,
    required this.title,
    required this.body,
    this.onTap,
    this.placeholder = false,
    this.editor,
  });

  final String title;
  final String body;
  final VoidCallback? onTap;
  final bool placeholder;
  final Widget? editor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 16, 14, 18),
        decoration: BoxDecoration(
          color: AppColors.navBar,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.goldMuted.withAlpha(30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            title.toText(
              color: AppColors.gold,
              fontSize: 12,
              fontWeight: AppStyle.w600,
              letterSpacing: 1.2,
            ),
            10.height,
            if (editor != null)
              editor!
            else
              body.toText(
                color: placeholder
                    ? AppColors.softGrayDim
                    : AppColors.secondaryText,
                fontSize: 14,
                lineHeight: 1.4,
              ),
          ],
        ),
      ),
    );
  }
}
