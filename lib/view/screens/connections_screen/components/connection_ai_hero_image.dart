import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';

/// Landscape Fumble AI generated image at the top of Connection Detail.
class ConnectionAiHeroImage extends StatelessWidget {
  const ConnectionAiHeroImage({
    super.key,
    this.imageUrl,
    this.assetPath = AppIcons.aiPlaceholder,
    this.height = 180,
    this.onTap,
  });

  final String? imageUrl;
  final String? assetPath;
  final double height;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim() ?? '';
    final asset = assetPath?.trim() ?? '';
    final hasNetwork = url.isNotEmpty;
    final hasAsset = asset.isNotEmpty;

    Widget child;
    if (hasNetwork) {
      child = CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: height,
        placeholder: (_, _) => const _AiImagePlaceholder(),
        errorWidget: (_, _, _) => hasAsset
            ? Image.asset(asset, fit: BoxFit.cover)
            : const _AiImagePlaceholder(),
      );
    } else if (hasAsset) {
      child = Image.asset(
        asset,
        fit: BoxFit.cover,
        width: double.infinity,
        height: height,
      );
    } else {
      child = const _AiImagePlaceholder();
    }

    return Material(
      color: AppColors.clear,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 1.2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14.5),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _AiImagePlaceholder extends StatelessWidget {
  const _AiImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surfaceElevated,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              AppIcons.autoAwesome,
              color: AppColors.primary,
              size: 28,
            ),
            8.height,
            AppConstant.aiImagePlaceholder.toText(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: AppStyle.w500,
            ),
          ],
        ),
      ),
    );
  }
}
