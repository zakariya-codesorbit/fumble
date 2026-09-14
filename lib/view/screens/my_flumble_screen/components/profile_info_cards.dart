import 'package:flutter/material.dart';

import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/utils/colors.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';

class ProfileInfoCard extends StatelessWidget {
  const ProfileInfoCard({
    super.key,
    required this.title,
    required this.body,
    required this.onEdit,
    this.placeholder = false,
  });

  final String title;
  final String body;
  final VoidCallback onEdit;
  final bool placeholder;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              GestureDetector(
                onTap: onEdit,
                child: const Icon(
                  AppIcons.edit,
                  size: 18,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
          10.height,
          body.toText(
            color: placeholder
                ? AppColors.softGrayDim
                : AppColors.secondaryText,
            fontSize: 16,
            lineHeight: 1.4,
          ),
        ],
      ),
    );
  }
}
