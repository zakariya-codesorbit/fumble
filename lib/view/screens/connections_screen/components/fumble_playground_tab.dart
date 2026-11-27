import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:fumble/core/navigation/app_routes.dart';
import 'package:fumble/core/navigation/router_navigator.dart';
import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/data/models/playground_adventure.dart';
import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/screens/connections_screen/fumble_playground_detail_screen.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';

/// Fumble Playground tab — adventure grid matching Connections design.
class FumblePlaygroundTab extends StatelessWidget {
  const FumblePlaygroundTab({super.key});

  @override
  Widget build(BuildContext context) {
    final adventures = PlaygroundAdventures.all;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppConstant.fumblePlaygroundEyebrow.toText(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: AppStyle.w600,
                  letterSpacing: 1.4,
                ),
                2.height,
                AppConstant.fumblePlaygroundHeadline.toText(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: AppStyle.w700,
                ),
                2.height,
                AppConstant.fumblePlaygroundTagline.toText(
                  color: AppColors.textTertiary,
                  fontSize: 11,
                  fontWeight: AppStyle.w500,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 0.8,
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 0.85,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final adventure = adventures[index];
              return _PlaygroundCard(
                adventure: adventure,
                onTap: () => push(
                  AppRoutes.fumblePlaygroundDetail,
                  arguments: FumblePlaygroundDetailArgs(
                    adventureId: adventure.id,
                  ),
                ),
              );
            }, childCount: adventures.length),
          ),
        ),
      ],
    );
  }
}

class _PlaygroundCard extends StatelessWidget {
  const _PlaygroundCard({required this.adventure, this.onTap});

  final PlaygroundAdventure adventure;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.clear,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 13,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(13),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: adventure.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (_, _) =>
                        const ColoredBox(color: AppColors.surfaceElevated),
                    errorWidget: (_, _, _) =>
                        Image.asset(AppIcons.aiPlaceholder, fit: BoxFit.cover),
                  ),
                ),
              ),
              Expanded(
                flex: 7,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      adventure.title.toText(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: AppStyle.w700,
                        letterSpacing: 0.4,
                        maxLine: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      4.height,
                      Expanded(
                        child: adventure.description.toText(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                          fontWeight: AppStyle.w400,
                          maxLine: 3,
                          overflow: TextOverflow.ellipsis,
                          lineHeight: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
