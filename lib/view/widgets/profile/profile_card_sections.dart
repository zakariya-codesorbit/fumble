import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/profile/profile_info_cards.dart';
import 'package:fumble/view/widgets/profile/profile_note_editor.dart';

/// Config for one optional section under the profile header.
class ProfileCardSection {
  const ProfileCardSection({
    this.body = '',
    this.emptyBody = '',
    this.editor,
    this.showEditIcon = false,
    this.onTap,
    this.visible = true,
  });

  final String body;
  final String emptyBody;
  final Widget? editor;
  final bool showEditIcon;
  final VoidCallback? onTap;
  final bool visible;

  bool get isEmpty => body.trim().isEmpty;
  String get displayBody => isEmpty ? emptyBody : body;
}

/// Divider + About Me / Location / Note + footer used across profile screens.
///
/// Pass `null` (or `visible: false`) to hide a section. Set [loading] to show
/// shimmer placeholders instead of about/location.
class ProfileCardSections extends StatelessWidget {
  const ProfileCardSections({
    super.key,
    this.showDivider = true,
    this.loading = false,
    this.aboutMe,
    this.location,
    this.note,
    this.noteController,
    this.noteEnabled = true,
    this.onNoteChanged,
    this.footerLabel,
    this.extra,
    this.bottomSpacing = 40,
  });

  final bool showDivider;
  final bool loading;
  final ProfileCardSection? aboutMe;
  final ProfileCardSection? location;
  final ProfileCardSection? note;
  final TextEditingController? noteController;
  final bool noteEnabled;
  final ValueChanged<String>? onNoteChanged;
  final String? footerLabel;
  final List<Widget>? extra;
  final double bottomSpacing;

  @override
  Widget build(BuildContext context) {
    final showAbout = aboutMe?.visible == true;
    final showLocation = location?.visible == true;
    final showNote = note?.visible == true || noteController != null;
    final hasContent = loading || showAbout || showLocation || showNote;

    return Column(
      children: [
        if (showDivider && hasContent) ...[
          24.height,
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          24.height,
        ] else if (!hasContent) ...[
          24.height,
        ],
        if (loading) ...[
          const _ProfileSectionsShimmer(),
          12.height,
        ] else ...[
          if (showAbout) ...[
            ProfileInfoCard(
              title: AppConstant.aboutMeLabel,
              body: aboutMe!.displayBody,
              placeholder: aboutMe!.isEmpty,
              showEditIcon: aboutMe!.showEditIcon,
              onTap: aboutMe!.onTap,
              editor: aboutMe!.editor,
            ),
            12.height,
          ],
          if (showLocation) ...[
            ProfileLocationCard(
              body: location!.displayBody,
              placeholder: location!.isEmpty,
              showEditIcon: location!.showEditIcon,
              onTap: location!.onTap,
              editor: location!.editor,
            ),
            12.height,
          ],
        ],
        if (showNote)
          ProfileInfoCard(
            title: AppConstant.noteLabel,
            body: note?.emptyBody.isNotEmpty == true
                ? note!.emptyBody
                : AppConstant.addNote,
            placeholder: true,
            showEditIcon: note?.showEditIcon ?? false,
            onTap: note?.onTap,
            editor: note?.editor ??
                (noteController != null
                    ? ProfileNoteEditor(
                        controller: noteController!,
                        enabled: noteEnabled,
                        onChanged: onNoteChanged,
                      )
                    : null),
          ),
        if (extra != null) ...extra!,
        if (footerLabel != null && footerLabel!.trim().isNotEmpty) ...[
          20.height,
          footerLabel!.toText(
            fontSize: 12,
            fontWeight: AppStyle.w500,
            color: AppColors.tertiaryText,
            textAlign: TextAlign.center,
          ),
        ],
        SizedBox(height: bottomSpacing),
      ],
    );
  }
}

class _ProfileSectionsShimmer extends StatelessWidget {
  const _ProfileSectionsShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ShimmerCard(titleWidth: 72, lines: const [1.0, 0.85, 0.55]),
        12.height,
        _ShimmerCard(titleWidth: 88, lines: const [0.7]),
      ],
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard({
    required this.titleWidth,
    required this.lines,
  });

  final double titleWidth;
  final List<double> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          _ShimmerBox(width: titleWidth, height: 12, radius: 6),
          12.height,
          for (var i = 0; i < lines.length; i++) ...[
            if (i > 0) 8.height,
            FractionallySizedBox(
              widthFactor: lines[i],
              child: const _ShimmerBox(
                width: double.infinity,
                height: 14,
                radius: 6,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
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
