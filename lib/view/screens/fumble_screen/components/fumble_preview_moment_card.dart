import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/services/location/fumble_location_service.dart';
import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/extention/widget_extension.dart';
import 'package:fumble/view/widgets/maps/fumble_moment_map.dart';

/// Date / time / location card for the fumble preview ("THE MOMENT").
class FumblePreviewMomentCard extends StatelessWidget {
  const FumblePreviewMomentCard({
    super.key,
    required this.dateLabel,
    required this.timeLabel,
    required this.locationLabel,
    this.locationPlaceholder = false,
    this.onLocationTap,
    this.mapLocation,
    this.isLoading = false,
  });

  final String dateLabel;
  final String timeLabel;
  final String locationLabel;
  final bool locationPlaceholder;
  final VoidCallback? onLocationTap;

  /// When set, shows an OSM map pin under the location row.
  final FumbleLocation? mapLocation;
  final bool isLoading;

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
          if (isLoading) ...[
            const _MomentShimmerBox(width: 96, height: 12, radius: 6),
            12.height,
            const _MomentShimmerBox(width: 160, height: 20, radius: 8),
            8.height,
            const _MomentShimmerBox(width: 72, height: 14, radius: 6),
            14.height,
            const Divider(height: 1, thickness: 1, color: AppColors.border),
            14.height,
            const Row(
              children: [
                _MomentShimmerBox(width: 18, height: 18, radius: 4),
                SizedBox(width: 8),
                Expanded(
                  child: _MomentShimmerBox(
                    width: double.infinity,
                    height: 14,
                    radius: 6,
                  ),
                ),
              ],
            ),
            14.height,
            const _MomentShimmerBox(
              width: double.infinity,
              height: 168,
              radius: 12,
            ),
          ] else ...[
            AppConstant.theMomentLabel.toText(
              color: AppColors.gold,
              fontSize: 12,
              fontWeight: AppStyle.w600,
              letterSpacing: 1.2,
            ),
            2.height,
            dateLabel.toText(
              fontSize: 16,
              fontWeight: AppStyle.w500,
              color: AppColors.white,
            ),
            4.height,
            timeLabel.toText(
              fontSize: 14,
              fontWeight: AppStyle.w500,
              color: AppColors.softGray,
            ),
            10.height,
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
                    color: locationPlaceholder
                        ? AppColors.softGrayDim
                        : AppColors.softGray,
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
            if (mapLocation != null) ...[
              10.height,
              FumbleMomentMap(location: mapLocation!),
            ],
          ],
        ],
      ),
    );
  }
}

class _MomentShimmerBox extends StatelessWidget {
  const _MomentShimmerBox({
    required this.width,
    required this.height,
    required this.radius,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceElevated,
      highlightColor: AppColors.softGrayDim.withValues(alpha: 0.35),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
