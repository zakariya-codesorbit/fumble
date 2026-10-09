import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/utils/app_assets.dart';
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
    this.showEditIcon = false,
  });

  final String title;
  final String body;
  final VoidCallback? onTap;
  final bool placeholder;
  final Widget? editor;
  final bool showEditIcon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
        decoration: BoxDecoration(
          color: AppColors.navBar,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: title.toText(
                    color: AppColors.gold,
                    fontSize: 12,
                    fontWeight: AppStyle.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                if (showEditIcon)
                  SvgPicture.asset(
                    AppIcons.iconEdit,
                    width: 16,
                    height: 16,
                    colorFilter: const ColorFilter.mode(
                      AppColors.warmGray,
                      BlendMode.srcIn,
                    ),
                  ),
              ],
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

class ProfileLocationCard extends StatelessWidget {
  const ProfileLocationCard({
    super.key,
    required this.body,
    this.onTap,
    this.placeholder = false,
    this.editor,
    this.showEditIcon = false,
  });

  final String body;
  final VoidCallback? onTap;
  final bool placeholder;
  final Widget? editor;
  final bool showEditIcon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
        decoration: BoxDecoration(
          color: AppColors.navBar,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(AppIcons.location, size: 18, color: AppColors.gold),
            10.width,
            Expanded(
              child: editor ??
                  body.toText(
                    color: placeholder
                        ? AppColors.softGrayDim
                        : AppColors.secondaryText,
                    fontSize: 14,
                    maxLine: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
            ),
            if (showEditIcon) ...[
              8.width,
              SvgPicture.asset(
                AppIcons.iconEdit,
                width: 16,
                height: 16,
                colorFilter: const ColorFilter.mode(
                  AppColors.warmGray,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
