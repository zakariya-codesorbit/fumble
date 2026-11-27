import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/feedback/custom_snackbar.dart';

class _PlaygroundAdventure {
  const _PlaygroundAdventure({
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  final String title;
  final String description;
  final String imageUrl;
}

/// Temporary adventure catalogue until FalAI / CMS content is wired.
const _adventures = <_PlaygroundAdventure>[
  _PlaygroundAdventure(
    title: 'MOON LANDING',
    description: 'One giant leap for the two of you.',
    imageUrl: 'https://images.unsplash.com/photo-1446776877081-d282a0f896e2?auto=format&fit=crop&w=800&q=80',
  ),
  _PlaygroundAdventure(
    title: 'ROLLERCOASTER',
    description: 'Hold on tight. This one\'s a scream.',
    imageUrl: 'https://images.unsplash.com/photo-1563990308267-1c6e4b099487?auto=format&fit=crop&w=800&q=80',
  ),
  _PlaygroundAdventure(
    title: 'BANK ROBBERY',
    description: 'Grab the bags. Don\'t look back.',
    imageUrl: 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&w=800&q=80',
  ),
  _PlaygroundAdventure(
    title: 'SKYDIVING',
    description: 'Jump together. Land later.',
    imageUrl: 'https://images.unsplash.com/photo-1521673461164-de300ebcfb17?auto=format&fit=crop&w=800&q=80',
  ),
  _PlaygroundAdventure(
    title: 'DINOSAUR ATTACK',
    description: 'Run. Don\'t feed the T-Rex.',
    imageUrl: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?auto=format&fit=crop&w=800&q=80',
  ),
  _PlaygroundAdventure(
    title: 'STREET RACE',
    description: 'Neon lights. No speed limits.',
    imageUrl: 'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?auto=format&fit=crop&w=800&q=80',
  ),
  _PlaygroundAdventure(
    title: 'DESERT CHASE',
    description: 'Hot pursuit across the dunes.',
    imageUrl: 'https://images.unsplash.com/photo-1509316785289-025f5b846b35?auto=format&fit=crop&w=800&q=80',
  ),
  _PlaygroundAdventure(
    title: 'BIG WAVE',
    description: 'Catch it or wipe out together.',
    imageUrl: 'https://images.unsplash.com/photo-1502680390469-be75caf25bf9?auto=format&fit=crop&w=800&q=80',
  ),
];

/// Fumble Playground tab — adventure grid matching Connections design.
class FumblePlaygroundTab extends StatelessWidget {
  const FumblePlaygroundTab({super.key});

  @override
  Widget build(BuildContext context) {
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
                  color: AppColors.textSecondary,
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
              final adventure = _adventures[index];
              return _PlaygroundCard(
                adventure: adventure,
                onTap: () => showAppToast(AppConstant.aiComingSoon),
              );
            }, childCount: _adventures.length),
          ),
        ),
      ],
    );
  }
}

class _PlaygroundCard extends StatelessWidget {
  const _PlaygroundCard({required this.adventure, this.onTap});

  final _PlaygroundAdventure adventure;
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
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: AppStyle.w700,
                        letterSpacing: 0.4,
                        maxLine: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      4.height,
                      Expanded(
                        child: adventure.description.toText(
                          color: AppColors.textSecondary,
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
