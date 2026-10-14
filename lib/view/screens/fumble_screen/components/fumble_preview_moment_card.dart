import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/extention/widget_extension.dart';

/// Date / time / location card for the fumble preview ("THE MOMENT").
class FumblePreviewMomentCard extends StatelessWidget {
  const FumblePreviewMomentCard({
    super.key,
    required this.dateLabel,
    required this.timeLabel,
    required this.locationLabel,
    this.onLocationTap,
  });

  final String dateLabel;
  final String timeLabel;
  final String locationLabel;
  final VoidCallback? onLocationTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.navBar,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppConstant.theMomentLabel.toText(
            color: AppColors.gold,
            fontSize: 12,
            fontWeight: AppStyle.w600,
            letterSpacing: 1.2,
          ),
          12.height,
          dateLabel.toText(
            fontSize: 18,
            fontWeight: AppStyle.w700,
            color: AppColors.white,
          ),
          4.height,
          timeLabel.toText(
            fontSize: 14,
            fontWeight: AppStyle.w500,
            color: AppColors.softGray,
          ),
          14.height,
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          14.height,
          Row(
            children: [
              Icon(AppIcons.location, size: 18, color: AppColors.gold),
              8.width,
              Expanded(
                child: locationLabel.toText(
                  fontSize: 14,
                  fontWeight: AppStyle.w500,
                  color: AppColors.softGray,
                  maxLine: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onLocationTap != null) ...[
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
          ).onPress(onLocationTap ?? () {}),
        ],
      ),
    );
  }
}
