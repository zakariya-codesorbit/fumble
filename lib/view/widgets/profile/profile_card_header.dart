import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/buttons/pill_button.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/extention/widget_extension.dart';
import 'package:fumble/view/widgets/inputs/custom_text_field.dart';
import 'package:fumble/view/widgets/inputs/phone_country_field.dart';
import 'package:fumble/view/widgets/layout/profile_avatar.dart';

/// Shared profile header for My Fumble, Fumble Preview, and Connection Detail.
///
/// Toggle visibility / editability per field so each screen can customize
/// without forking the layout.
class ProfileCardHeader extends StatelessWidget {
  const ProfileCardHeader({
    super.key,
    required this.name,
    this.eyebrow,
    this.photoUrl,
    this.localFile,
    this.svg,
    this.avatarSize = 120,
    this.onPhotoTap,
    this.avatarLoading = false,
    // Name
    this.showNameEditIcon = false,
    this.editingName = false,
    this.nameController,
    this.onNameTap,
    this.onNameChanged,
    this.onNameTapOutside,
    // Bio
    this.bio,
    this.showBio = true,
    this.hideBioWhenEmpty = false,
    this.bioPlaceholder = AppConstant.addBio,
    this.editingBio = false,
    this.bioController,
    this.onBioTap,
    this.onBioChanged,
    this.onBioTapOutside,
    // Contact
    this.phone,
    this.email,
    this.showContact = true,
    this.contactLoading = false,
    this.emptyPhoneLabel = AppConstant.addPhone,
    this.emptyEmailLabel = 'No email',
    this.editingPhone = false,
    this.phoneController,
    this.phoneFieldKey,
    this.phoneDialCode,
    this.phoneCountryCode,
    this.onPhoneTap,
    this.onPhoneChanged,
    this.onPhoneCountryChanged,
    this.onPhoneTapOutside,
    // Actions
    this.showActions = true,
    this.showEmail = true,
    this.onCall,
    this.onText,
    this.topSpacing = 20,
  });

  final String name;
  final String? eyebrow;
  final String? photoUrl;
  final File? localFile;
  final String? svg;
  final double avatarSize;
  final VoidCallback? onPhotoTap;
  final bool avatarLoading;

  final bool showNameEditIcon;
  final bool editingName;
  final TextEditingController? nameController;
  final VoidCallback? onNameTap;
  final ValueChanged<String>? onNameChanged;
  final VoidCallback? onNameTapOutside;

  final String? bio;
  final bool showBio;
  final bool hideBioWhenEmpty;
  final String bioPlaceholder;
  final bool editingBio;
  final TextEditingController? bioController;
  final VoidCallback? onBioTap;
  final ValueChanged<String>? onBioChanged;
  final VoidCallback? onBioTapOutside;

  final String? phone;
  final String? email;
  final bool showContact;
  final bool contactLoading;
  final String emptyPhoneLabel;
  final String emptyEmailLabel;
  final bool editingPhone;
  final TextEditingController? phoneController;
  final GlobalKey<PhoneCountryFieldState>? phoneFieldKey;
  final String? phoneDialCode;
  final String? phoneCountryCode;
  final VoidCallback? onPhoneTap;
  final ValueChanged<String>? onPhoneChanged;
  final VoidCallback? onPhoneCountryChanged;
  final VoidCallback? onPhoneTapOutside;

  final bool showActions;
  final bool showEmail;
  final VoidCallback? onCall;
  final VoidCallback? onText;
  final double topSpacing;

  @override
  Widget build(BuildContext context) {
    final bioText = bio?.trim() ?? '';
    final showBioRow =
        showBio && (editingBio || !hideBioWhenEmpty || bioText.isNotEmpty);

    return Column(
      children: [
        SizedBox(height: topSpacing),
        if (eyebrow != null && eyebrow!.trim().isNotEmpty) ...[
          eyebrow!.toText(
            color: AppColors.gold,
            fontSize: 14,
            fontWeight: AppStyle.w600,
            letterSpacing: 1.2,
            textAlign: TextAlign.center,
          ),
          16.height,
        ],
        if (avatarLoading)
          _ShimmerBox(
            width: avatarSize,
            height: avatarSize,
            radius: avatarSize / 2,
          )
        else
          ProfileAvatar(
            photoUrl: photoUrl,
            localFile: localFile,
            svg: svg,
            name: name,
            size: avatarSize,
            onTap: onPhotoTap,
          ),
        16.height,
        _NameRow(
          name: name,
          showEditIcon: showNameEditIcon,
          editing: editingName,
          controller: nameController,
          onTap: onNameTap,
          onChanged: onNameChanged,
          onTapOutside: onNameTapOutside,
        ),
        if (contactLoading) ...[
          10.height,
          const _ShimmerBox(width: 180, height: 14, radius: 8),
          18.height,
          const _ShimmerBox(width: 140, height: 16, radius: 8),
          10.height,
          const _ShimmerBox(width: 200, height: 16, radius: 8),
          20.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              _ShimmerBox(width: 85, height: 38, radius: 99),
              SizedBox(width: 12),
              _ShimmerBox(width: 85, height: 38, radius: 99),
            ],
          ),
        ] else ...[
          if (showBioRow) ...[
            6.height,
            _BioRow(
              bioText: bioText,
              placeholder: bioPlaceholder,
              editing: editingBio,
              controller: bioController,
              onTap: onBioTap,
              onChanged: onBioChanged,
              onTapOutside: onBioTapOutside,
            ),
          ],
          if (showContact) ...[
            18.height,
            if (editingPhone &&
                phoneController != null &&
                phoneFieldKey != null)
              TapRegion(
                onTapOutside: (_) {
                  FocusManager.instance.primaryFocus?.unfocus();
                  onPhoneTapOutside?.call();
                },
                child: PhoneCountryField(
                  key: phoneFieldKey,
                  controller: phoneController!,
                  initialDialCode: phoneDialCode,
                  initialCountryCode: phoneCountryCode,
                  textInputAction: TextInputAction.done,
                  onChanged: onPhoneChanged,
                  onCountryChanged: onPhoneCountryChanged,
                  onSubmitted: (_) {
                    FocusManager.instance.primaryFocus?.unfocus();
                    onPhoneTapOutside?.call();
                  },
                ),
              )
            else
              _ContactLine(
                value: phone,
                emptyLabel: emptyPhoneLabel,
                onTap: onPhoneTap,
              ),
            if (showEmail) ...[
              10.height,
              _ContactLine(
                value: email,
                emptyLabel: emptyEmailLabel,
                onTap: null,
              ),
            ],
          ],
          if (showActions) ...[
            20.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PillButton(
                  label: AppConstant.call,
                  icon: AppIcons.phone,
                  foregroundColor: AppColors.gold,
                  borderColor: AppColors.goldMuted,
                  onTap: onCall,
                ),
                12.width,
                PillButton(
                  label: AppConstant.text,
                  icon: AppIcons.chat,
                  backgroundColor: AppColors.surfaceElevated,
                  foregroundColor: AppColors.white,
                  borderColor: AppColors.softGrayDim,
                  onTap: onText,
                ),
              ],
            ),
          ],
        ],
      ],
    );
  }
}

class _NameRow extends StatelessWidget {
  const _NameRow({
    required this.name,
    required this.showEditIcon,
    required this.editing,
    this.controller,
    this.onTap,
    this.onChanged,
    this.onTapOutside,
  });

  final String name;
  final bool showEditIcon;
  final bool editing;
  final TextEditingController? controller;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTapOutside;

  @override
  Widget build(BuildContext context) {
    if (editing && controller != null) {
      return CustomTextField(
        controller: controller!,
        hintText: name,
        onChanged: onChanged,
        onTapOutside: onTapOutside,
        autofocus: true,
      );
    }

    final nameText = name.toText(
      fontSize: 28,
      fontWeight: AppStyle.w700,
      textAlign: TextAlign.center,
    );

    if (!showEditIcon && onTap == null) {
      return nameText;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(child: nameText),
        if (showEditIcon) ...[
          8.width,
          SvgPicture.asset(
            AppIcons.iconEdit,
            width: 18,
            height: 18,
            colorFilter: const ColorFilter.mode(
              AppColors.warmGray,
              BlendMode.srcIn,
            ),
          ),
        ],
      ],
    ).onPress(onTap ?? () {});
  }
}

class _BioRow extends StatelessWidget {
  const _BioRow({
    required this.bioText,
    required this.placeholder,
    required this.editing,
    this.controller,
    this.onTap,
    this.onChanged,
    this.onTapOutside,
  });

  final String bioText;
  final String placeholder;
  final bool editing;
  final TextEditingController? controller;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTapOutside;

  @override
  Widget build(BuildContext context) {
    if (editing && controller != null) {
      return CustomTextField(
        controller: controller!,
        hintText: AppConstant.bioHint,
        maxLine: 3,
        onChanged: onChanged,
        onTapOutside: onTapOutside,
        autofocus: true,
      );
    }

    final text = (bioText.isNotEmpty ? bioText : placeholder).toText(
      fontSize: 14,
      fontWeight: AppStyle.w500,
      color: bioText.isNotEmpty
          ? AppColors.tertiaryText
          : AppColors.softGrayDim,
      textAlign: TextAlign.center,
      maxLine: 3,
      overflow: TextOverflow.ellipsis,
    );

    if (onTap == null) return text;
    return text.onPress(onTap!);
  }
}

class _ContactLine extends StatelessWidget {
  const _ContactLine({
    required this.value,
    required this.emptyLabel,
    this.onTap,
  });

  final String? value;
  final String emptyLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final raw = value?.trim() ?? '';
    final hasValue = raw.isNotEmpty;
    final display = hasValue ? raw : emptyLabel;

    final text = display.toText(
      fontSize: 16,
      fontWeight: hasValue ? AppStyle.w600 : AppStyle.w500,
      color: hasValue ? AppColors.white : AppColors.softGrayDim,
      textAlign: TextAlign.center,
      maxLine: 1,
      overflow: TextOverflow.ellipsis,
    );

    return Center(child: onTap != null ? text.onPress(onTap!) : text);
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
