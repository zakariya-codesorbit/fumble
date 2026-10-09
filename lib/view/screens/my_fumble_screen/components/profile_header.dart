import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/extention/widget_extension.dart';
import 'package:fumble/view/widgets/inputs/custom_text_field.dart';
import 'package:fumble/view/widgets/inputs/custom_toggle.dart';
import 'package:fumble/view/widgets/layout/profile_avatar.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.name,
    required this.photoUrl,
    this.localFile,
    this.svg,
    this.bio,
    this.phone,
    this.email,
    this.sharePhone = true,
    this.shareEmail = true,
    this.editingName = false,
    this.editingBio = false,
    this.nameController,
    this.bioController,
    this.onNameTap,
    this.onNameChanged,
    this.onNameTapOutside,
    this.onBioTap,
    this.onBioChanged,
    this.onBioTapOutside,
    this.onPhotoTap,
    this.onSharePhoneChanged,
    this.onShareEmailChanged,
  });

  final String name;
  final String? photoUrl;
  final File? localFile;
  final String? svg;
  final String? bio;
  final String? phone;
  final String? email;
  final bool sharePhone;
  final bool shareEmail;
  final bool editingName;
  final bool editingBio;
  final TextEditingController? nameController;
  final TextEditingController? bioController;
  final VoidCallback? onNameTap;
  final ValueChanged<String>? onNameChanged;
  final VoidCallback? onNameTapOutside;
  final VoidCallback? onBioTap;
  final ValueChanged<String>? onBioChanged;
  final VoidCallback? onBioTapOutside;
  final VoidCallback? onPhotoTap;
  final ValueChanged<bool>? onSharePhoneChanged;
  final ValueChanged<bool>? onShareEmailChanged;

  @override
  Widget build(BuildContext context) {
    final bioText = bio?.trim() ?? '';
    return Column(
      children: [
        20.height,
        ProfileAvatar(
          photoUrl: photoUrl,
          localFile: localFile,
          svg: svg,
          name: name,
          size: 120,
          onTap: onPhotoTap,
        ),
        20.height,
        if (editingName && nameController != null)
          CustomTextField(
            controller: nameController!,
            hintText: name,
            onChanged: onNameChanged,
            onTapOutside: onNameTapOutside,
            autofocus: true,
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: name.toText(
                  fontSize: 28,
                  fontWeight: AppStyle.w700,
                  textAlign: TextAlign.center,
                ),
              ),
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
          ).onPress(onNameTap ?? () {}),
        10.height,
        if (editingBio && bioController != null)
          CustomTextField(
            controller: bioController!,
            hintText: AppConstant.bioHint,
            maxLine: 3,
            onChanged: onBioChanged,
            onTapOutside: onBioTapOutside,
            autofocus: true,
          )
        else
          (bioText.isNotEmpty ? bioText : AppConstant.addBio)
              .toText(
                fontSize: 14,
                fontWeight: AppStyle.w500,
                color: bioText.isNotEmpty
                    ? AppColors.tertiaryText
                    : AppColors.softGrayDim,
                textAlign: TextAlign.center,
                maxLine: 3,
                overflow: TextOverflow.ellipsis,
              )
              .onPress(onBioTap ?? () {}),
        16.height,
        _ContactVisibilityRow(
          value: phone,
          visible: sharePhone,
          emptyLabel: 'No phone number',
          onVisibilityChanged: onSharePhoneChanged,
        ),
        10.height,
        _ContactVisibilityRow(
          value: email,
          visible: shareEmail,
          emptyLabel: 'No email',
          onVisibilityChanged: onShareEmailChanged,
        ),
      ],
    );
  }
}

class _ContactVisibilityRow extends StatelessWidget {
  const _ContactVisibilityRow({
    required this.value,
    required this.visible,
    required this.emptyLabel,
    this.onVisibilityChanged,
  });

  final String? value;
  final bool visible;
  final String emptyLabel;
  final ValueChanged<bool>? onVisibilityChanged;

  @override
  Widget build(BuildContext context) {
    final raw = value?.trim() ?? '';
    final hasValue = raw.isNotEmpty;
    final display = !hasValue ? emptyLabel : raw;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: display.toText(
            fontSize: 16,
            fontWeight: hasValue ? AppStyle.w600 : AppStyle.w500,
            color: hasValue ? AppColors.white : AppColors.softGrayDim,
            textAlign: TextAlign.center,
            maxLine: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (hasValue && onVisibilityChanged != null) ...[
          10.width,
          CustomToggle(
            value: visible,
            onChanged: onVisibilityChanged!,
          ),
        ],
      ],
    );
  }
}
