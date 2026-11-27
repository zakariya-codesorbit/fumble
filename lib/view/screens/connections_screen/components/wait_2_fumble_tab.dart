import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/feedback/custom_snackbar.dart';
import 'package:fumble/view/widgets/media/ai_test_video_player.dart';

enum _Wait2Mode { makeYourOwn, presetVideos }

enum _MediaSource { fromGallery, generateWithAi }

/// Wait 2 Fumble tab — create memory while waiting for a Fumble.
class Wait2FumbleTab extends StatefulWidget {
  const Wait2FumbleTab({super.key});

  @override
  State<Wait2FumbleTab> createState() => _Wait2FumbleTabState();
}

class _Wait2FumbleTabState extends State<Wait2FumbleTab> {
  final _who = TextEditingController();
  final _where = TextEditingController();
  final _what = TextEditingController();
  var _mode = _Wait2Mode.makeYourOwn;
  var _mediaSource = _MediaSource.fromGallery;

  @override
  void dispose() {
    _who.dispose();
    _where.dispose();
    _what.dispose();
    super.dispose();
  }

  void _comingSoon() => showAppToast(AppConstant.aiComingSoon);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 28.h),
      children: [
        _PillSegmentedControl<_Wait2Mode>(
          leftValue: _Wait2Mode.makeYourOwn,
          rightValue: _Wait2Mode.presetVideos,
          leftLabel: AppConstant.wait2MakeYourOwn,
          rightLabel: AppConstant.wait2PresetVideos,
          selected: _mode,
          onChanged: (mode) => setState(() => _mode = mode),
        ),
        16.height,
        if (_mode == _Wait2Mode.makeYourOwn) ...[
          _MakeYourOwnCard(
            whoController: _who,
            whereController: _where,
            whatController: _what,
            mediaSource: _mediaSource,
            onMediaSourceChanged: (source) =>
                setState(() => _mediaSource = source),
            onAddMedia: _comingSoon,
            onGenerateImage: _comingSoon,
            onGenerateVideo: _comingSoon,
          ),
          16.height,
          const _Wait2PreviewCard(),
        ] else
          Padding(
            padding: EdgeInsets.symmetric(vertical: 48.h),
            child: Center(
              child: AppConstant.wait2PresetComingSoon.toText(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: AppStyle.w500,
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

class _MakeYourOwnCard extends StatelessWidget {
  const _MakeYourOwnCard({
    required this.whoController,
    required this.whereController,
    required this.whatController,
    required this.mediaSource,
    required this.onMediaSourceChanged,
    required this.onAddMedia,
    required this.onGenerateImage,
    required this.onGenerateVideo,
  });

  final TextEditingController whoController;
  final TextEditingController whereController;
  final TextEditingController whatController;
  final _MediaSource mediaSource;
  final ValueChanged<_MediaSource> onMediaSourceChanged;
  final VoidCallback onAddMedia;
  final VoidCallback onGenerateImage;
  final VoidCallback onGenerateVideo;

  @override
  Widget build(BuildContext context) {
    return _DashedBorderBox(
      child: Padding(
        padding: EdgeInsets.fromLTRB(14.w, 16.h, 14.w, 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppConstant.whileYouWait2Fumble.toText(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: AppStyle.w700,
              letterSpacing: 1.1,
              textAlign: TextAlign.start,
            ),
            10.height,
            AppConstant.wait2CaptureHint.toText(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: AppStyle.w400,
              textAlign: TextAlign.start,
              lineHeight: 1.4,
              maxLine: 4,
            ),
            16.height,
            _Wait2Field(
              controller: whoController,
              hint: AppConstant.wait2WhoOrWhat,
            ),
            10.height,
            _Wait2Field(
              controller: whereController,
              hint: AppConstant.wait2Where,
            ),
            10.height,
            _Wait2Field(
              controller: whatController,
              hint: AppConstant.wait2WhatHappened,
              maxLines: 4,
            ),
            14.height,
            Align(
              alignment: Alignment.centerLeft,
              child: _AddMediaButton(onTap: onAddMedia),
            ),
            14.height,
            Center(
              child: _PillSegmentedControl<_MediaSource>(
                leftValue: _MediaSource.fromGallery,
                rightValue: _MediaSource.generateWithAi,
                leftLabel: AppConstant.wait2FromGallery,
                rightLabel: AppConstant.wait2GenerateWithAi,
                selected: mediaSource,
                onChanged: onMediaSourceChanged,
                compact: true,
              ),
            ),
            16.height,
            _OutlinedActionButton(
              label: AppConstant.generateImageMemory,
              icon: AppIcons.photoLibrary,
              onTap: onGenerateImage,
            ),
            10.height,
            _OutlinedActionButton(
              label: AppConstant.generateVideoMemory,
              icon: AppIcons.videocam,
              onTap: onGenerateVideo,
            ),
          ],
        ),
      ),
    );
  }
}

class _Wait2PreviewCard extends StatelessWidget {
  const _Wait2PreviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 0),
            child: const AiTestVideoPlayer(aspectRatio: 3 / 4),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryMuted,
                        shape: BoxShape.circle,
                      ),
                      child: 'IT'.toText(
                        color: AppColors.textOnCoin,
                        fontSize: 14,
                        fontWeight: AppStyle.w700,
                      ),
                    ),
                    10.width,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppConstant.wait2SampleTitle.toText(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: AppStyle.w700,
                            maxLine: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          2.height,
                          AppConstant.connectionsTabWait2Fumble.toText(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: AppStyle.w600,
                            letterSpacing: 0.8,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        '7 November 2026, 4:47'.toText(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                          fontWeight: AppStyle.w500,
                        ),
                        6.height,
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              AppIcons.iconEdit,
                              width: 14,
                              height: 14,
                              colorFilter: const ColorFilter.mode(
                                AppColors.primary,
                                BlendMode.srcIn,
                              ),
                            ),
                            4.width,
                            AppConstant.editLabel.toText(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: AppStyle.w600,
                              letterSpacing: 0.8,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                10.height,
                Row(
                  children: [
                    const Icon(
                      AppIcons.location,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    6.width,
                    Expanded(
                      child: AppConstant.wait2SampleLocation.toText(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                        fontWeight: AppStyle.w500,
                        maxLine: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                10.height,
                AppConstant.wait2SampleCaption.toText(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: AppStyle.w400,
                  maxLine: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PillSegmentedControl<T> extends StatelessWidget {
  const _PillSegmentedControl({
    required this.leftValue,
    required this.rightValue,
    required this.leftLabel,
    required this.rightLabel,
    required this.selected,
    required this.onChanged,
    this.compact = false,
  });

  final T leftValue;
  final T rightValue;
  final String leftLabel;
  final String rightLabel;
  final T selected;
  final ValueChanged<T> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppStyle.radiusPill),
        border: Border.all(color: AppColors.navDivider),
      ),
      child: Row(
        children: [
          Expanded(
            child: _PillSegment(
              label: leftLabel,
              selected: selected == leftValue,
              compact: compact,
              onTap: () => onChanged(leftValue),
            ),
          ),
          Expanded(
            child: _PillSegment(
              label: rightLabel,
              selected: selected == rightValue,
              compact: compact,
              onTap: () => onChanged(rightValue),
            ),
          ),
        ],
      ),
    );
  }
}

class _PillSegment extends StatelessWidget {
  const _PillSegment({
    required this.label,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.clear,
      borderRadius: BorderRadius.circular(AppStyle.radiusPill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppStyle.radiusPill),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: compact ? 10 : 12),
          child: label.toText(
            color: selected ? AppColors.onPrimary : AppColors.textSecondary,
            fontSize: compact ? 10 : 11,
            fontWeight: AppStyle.w700,
            letterSpacing: 0.6,
            textAlign: TextAlign.center,
            maxLine: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

class _Wait2Field extends StatelessWidget {
  const _Wait2Field({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      minLines: maxLines > 1 ? maxLines : 1,
      cursorColor: AppColors.primary,
      style: TextStyle(
        fontSize: 14,
        fontWeight: AppStyle.w400,
        color: AppColors.textPrimary,
        fontFamily: AppStyle.fontFamily,
        fontFamilyFallback: AppStyle.fontFamilyFallback,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 14,
          fontWeight: AppStyle.w400,
          color: AppColors.textDisabled,
          fontFamily: AppStyle.fontFamily,
          fontFamilyFallback: AppStyle.fontFamilyFallback,
        ),
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14,
          vertical: maxLines > 1 ? 14 : 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
    );
  }
}

class _AddMediaButton extends StatelessWidget {
  const _AddMediaButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.clear,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: CustomPaint(
          foregroundPainter: _DashedBorderPainter(
            color: AppColors.primary,
            radius: 10,
            strokeWidth: 1.2,
            dashWidth: 2.5,
            dashGap: 2.5,
          ),
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(
              AppIcons.addPhoto,
              color: AppColors.primary,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlinedActionButton extends StatelessWidget {
  const _OutlinedActionButton({
    required this.label,
    required this.icon,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.clear,
      borderRadius: BorderRadius.circular(AppStyle.radiusPill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppStyle.radiusPill),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppStyle.radiusPill),
            border: Border.all(color: AppColors.primary, width: 1.2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              8.width,
              label.toText(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: AppStyle.w600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderBox extends StatelessWidget {
  const _DashedBorderBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Same fill as Fumbled / Half Fumble list cards (`AppColors.surface`).
    return CustomPaint(
      foregroundPainter: _DashedBorderPainter(
        color: AppColors.primary,
        radius: 15,
        strokeWidth: 1.2,
        dashWidth: 2.5,
        dashGap: 2.5,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(15),
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashGap,
  });

  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(
      Offset(strokeWidth / 2, strokeWidth / 2) &
          Size(size.width - strokeWidth, size.height - strokeWidth),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.radius != radius ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashGap != dashGap;
  }
}
