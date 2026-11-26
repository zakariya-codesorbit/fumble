import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/screens/fumble_screen/components/fumble_preview_record_memory.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/extention/widget_extension.dart';

enum ConnectionAiTab { record, generation, video }

/// Tabbed AI Group card — Record Memory / AI Generation / AI Video Memory.
class ConnectionAiGroupCard extends StatelessWidget {
  const ConnectionAiGroupCard({
    super.key,
    required this.tab,
    required this.onTabChanged,
    required this.noteController,
    required this.promptController,
    required this.isListening,
    required this.noteEnabled,
    this.aiImageUrl,
    this.onRecordTap,
    this.onGenerateTap,
    this.onRegenerateVideoTap,
    this.onEditTap,
  });

  final ConnectionAiTab tab;
  final ValueChanged<ConnectionAiTab> onTabChanged;
  final TextEditingController noteController;
  final TextEditingController promptController;
  final bool isListening;
  final bool noteEnabled;
  final String? aiImageUrl;
  final VoidCallback? onRecordTap;
  final VoidCallback? onGenerateTap;
  final VoidCallback? onRegenerateVideoTap;
  final VoidCallback? onEditTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 14, 10, 0),
            child: Row(
              children: [
                for (final entry in ConnectionAiTab.values) ...[
                  if (entry.index > 0) 4.width,
                  Expanded(
                    child: _AiTabChip(
                      label: switch (entry) {
                        ConnectionAiTab.record => AppConstant.recordMemoryTab,
                        ConnectionAiTab.generation =>
                          AppConstant.aiGenerationTab,
                        ConnectionAiTab.video => AppConstant.aiVideoMemoryTab,
                      },
                      selected: tab == entry,
                      onTap: () => onTabChanged(entry),
                    ),
                  ),
                ],
              ],
            ),
          ),
          12.height,
          const Divider(height: 1, thickness: 1, color: AppColors.navDivider),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: switch (tab) {
              ConnectionAiTab.record => _RecordMemoryPanel(
                noteController: noteController,
                enabled: noteEnabled,
                isListening: isListening,
                onRecordTap: onRecordTap,
              ),
              ConnectionAiTab.generation => _AiGenerationPanel(
                noteController: noteController,
                promptController: promptController,
                imageUrl: aiImageUrl,
                onGenerateTap: onGenerateTap,
              ),
              ConnectionAiTab.video => _AiVideoPanel(
                noteController: noteController,
                imageUrl: aiImageUrl,
                onRegenerateTap: onRegenerateVideoTap,
                onEditTap: onEditTap,
              ),
            },
          ),
        ],
      ),
    );
  }
}

class _AiTabChip extends StatelessWidget {
  const _AiTabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          children: [
            label.toText(
              color: selected ? AppColors.primary : AppColors.textSecondary,
              fontSize: 10,
              fontWeight: AppStyle.w600,
              letterSpacing: 0.4,
              textAlign: TextAlign.center,
              maxLine: 2,
            ),
            8.height,
            Container(
              height: 2,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.clear,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordMemoryPanel extends StatelessWidget {
  const _RecordMemoryPanel({
    required this.noteController,
    required this.enabled,
    required this.isListening,
    this.onRecordTap,
  });

  final TextEditingController noteController;
  final bool enabled;
  final bool isListening;
  final VoidCallback? onRecordTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            color: AppColors.inputFill,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppConstant.sayItLikeThis.toText(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: AppStyle.w600,
                letterSpacing: 1.2,
              ),
              12.height,
              for (var i = 0; i < AppConstant.memoryPrompts.length; i++) ...[
                if (i > 0) 8.height,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    '${i + 1}'.toText(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: AppStyle.w700,
                    ),
                    8.width,
                    Expanded(
                      child: AppConstant.memoryPrompts[i].toText(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: AppStyle.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        14.height,
        FumblePreviewRecordMemory(isListening: isListening, onTap: onRecordTap),
        14.height,
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 16, 14, 14),
          decoration: BoxDecoration(
            color: AppColors.inputFill,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 1.2),
          ),
          child: TextField(
            controller: noteController,
            enabled: enabled,
            maxLines: 5,
            minLines: 3,
            cursorColor: AppColors.primary,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: AppColors.textPrimary,
              fontFamily: AppStyle.fontFamily,
              fontFamilyFallback: AppStyle.fontFamilyFallback,
            ),
            decoration: InputDecoration(
              isDense: true,
              filled: false,
              hintText: AppConstant.typeMemoryHint,
              hintStyle: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: AppColors.textDisabled,
                fontFamily: AppStyle.fontFamily,
                fontFamilyFallback: AppStyle.fontFamilyFallback,
              ),
              contentPadding: const EdgeInsets.only(top: 4, left: 2),
              border: InputBorder.none,
            ),
          ),
        ),
        12.height,
        Row(
          children: [
            Expanded(
              child: AppConstant.savedPermanentlyWithFumble.toText(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: AppStyle.w400,
              ),
            ),
            8.width,
            AppConstant.aiMemoryLabel.toText(
              color: AppColors.primary,
              fontSize: 11,
              fontWeight: AppStyle.w600,
              letterSpacing: 1.1,
            ),
            6.width,
            const Icon(
              AppIcons.autoAwesome,
              size: 14,
              color: AppColors.primary,
            ),
          ],
        ),
      ],
    );
  }
}

class _AiGenerationPanel extends StatelessWidget {
  const _AiGenerationPanel({
    required this.noteController,
    required this.promptController,
    this.imageUrl,
    this.onGenerateTap,
  });

  final TextEditingController noteController;
  final TextEditingController promptController;
  final String? imageUrl;
  final VoidCallback? onGenerateTap;

  @override
  Widget build(BuildContext context) {
    final memory = noteController.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppConstant.paintedFromYourMemory.toText(
          color: AppColors.primary,
          fontSize: 11,
          fontWeight: AppStyle.w600,
          letterSpacing: 1.2,
        ),
        12.height,
        (memory.isEmpty ? AppConstant.typeMemoryHint : '“$memory”').toText(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: AppStyle.w400,
          fontStyle: FontStyle.italic,
          maxLine: 6,
        ),
        14.height,
        _AiMediaFrame(imageUrl: imageUrl, height: 220),
        14.height,
        AppConstant.addToIt.toText(
          color: AppColors.primary,
          fontSize: 11,
          fontWeight: AppStyle.w600,
          letterSpacing: 1.2,
        ),
        8.height,
        Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: AppColors.inputFill,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 1.2),
          ),
          child: TextField(
            controller: promptController,
            maxLines: 3,
            minLines: 2,
            cursorColor: AppColors.primary,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              fontFamily: AppStyle.fontFamily,
              fontFamilyFallback: AppStyle.fontFamilyFallback,
            ),
            decoration: InputDecoration(
              isDense: true,
              filled: false,
              hintText: AppConstant.addToItHint,
              hintStyle: TextStyle(
                fontSize: 13,
                color: AppColors.textDisabled,
                fontFamily: AppStyle.fontFamily,
                fontFamilyFallback: AppStyle.fontFamilyFallback,
              ),
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
            ),
          ),
        ),
        16.height,
        _OutlinedAiButton(
          label: AppConstant.generate,
          icon: AppIcons.autoAwesome,
          onTap: onGenerateTap,
        ),
      ],
    );
  }
}

class _AiVideoPanel extends StatelessWidget {
  const _AiVideoPanel({
    required this.noteController,
    this.imageUrl,
    this.onRegenerateTap,
    this.onEditTap,
  });

  final TextEditingController noteController;
  final String? imageUrl;
  final VoidCallback? onRegenerateTap;
  final VoidCallback? onEditTap;

  @override
  Widget build(BuildContext context) {
    final memory = noteController.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: AppConstant.filmedFromYourMemory.toText(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: AppStyle.w600,
                letterSpacing: 1.2,
              ),
            ),
            AppConstant.editLabel
                .toText(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: AppStyle.w600,
                  letterSpacing: 1,
                )
                .onPress(onEditTap ?? () {}),
          ],
        ),
        12.height,
        (memory.isEmpty ? AppConstant.typeMemoryHint : '“$memory”').toText(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: AppStyle.w400,
          fontStyle: FontStyle.italic,
          maxLine: 6,
        ),
        14.height,
        _AiMediaFrame(imageUrl: imageUrl, height: 260, showPlay: true),
        16.height,
        _OutlinedAiButton(
          label: AppConstant.regenerateVideo,
          icon: AppIcons.camera,
          onTap: onRegenerateTap,
        ),
      ],
    );
  }
}

class _AiMediaFrame extends StatelessWidget {
  const _AiMediaFrame({
    this.imageUrl,
    this.height = 220,
    this.showPlay = false,
  });

  final String? imageUrl;
  final double height;
  final bool showPlay;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim() ?? '';
    final hasImage = url.isNotEmpty;

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasImage)
            CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              placeholder: (_, _) =>
                  const ColoredBox(color: AppColors.surfaceElevated),
              errorWidget: (_, _, _) =>
                  const ColoredBox(color: AppColors.surfaceElevated),
            )
          else
            const Center(
              child: Icon(
                AppIcons.autoAwesome,
                color: AppColors.primary,
                size: 32,
              ),
            ),
          if (showPlay)
            const Center(
              child: Icon(
                Icons.play_circle_fill_rounded,
                color: AppColors.textPrimary,
                size: 56,
              ),
            ),
        ],
      ),
    );
  }
}

class _OutlinedAiButton extends StatelessWidget {
  const _OutlinedAiButton({
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
