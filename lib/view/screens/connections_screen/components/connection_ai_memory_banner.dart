import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';

/// Landscape AI Memory image with badge — used on connection list cards.
class ConnectionAiMemoryBanner extends StatelessWidget {
  const ConnectionAiMemoryBanner({
    super.key,
    this.imageUrl,
    this.assetPath = AppIcons.aiPlaceholder,
    this.height = 168,
    this.borderRadius = const BorderRadius.vertical(top: Radius.circular(14)),
  });

  final String? imageUrl;
  final String? assetPath;
  final double height;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim() ?? '';
    final asset = assetPath?.trim() ?? '';
    final hasNetwork = url.isNotEmpty;
    final hasAsset = asset.isNotEmpty;

    Widget media;
    if (hasNetwork) {
      media = CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: height,
        placeholder: (_, _) => const ColoredBox(color: AppColors.surfaceElevated),
        errorWidget: (_, _, _) => hasAsset
            ? Image.asset(asset, fit: BoxFit.cover)
            : const ColoredBox(color: AppColors.surfaceElevated),
      );
    } else if (hasAsset) {
      media = Image.asset(
        asset,
        fit: BoxFit.cover,
        width: double.infinity,
        height: height,
      );
    } else {
      media = ColoredBox(
        color: AppColors.surfaceElevated,
        child: Center(
          child: Icon(
            AppIcons.autoAwesome,
            color: AppColors.primary,
            size: 28,
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            media,
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.onPrimary.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(AppStyle.radiusPill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      AppIcons.autoAwesome,
                      size: 12,
                      color: AppColors.primary,
                    ),
                    6.width,
                    AppConstant.aiMemoryLabel.toText(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: AppStyle.w700,
                      letterSpacing: 1.1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
