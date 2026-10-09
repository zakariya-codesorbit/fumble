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
import 'package:fumble/view/screens/my_fumble_screen/components/pill_button.dart';
import 'package:fumble/view/widgets/inputs/custom_text_field.dart';
import 'package:fumble/view/widgets/inputs/phone_country_field.dart';
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
    this.editingName = false,
    this.editingBio = false,
    this.editingPhone = false,
    this.nameController,
    this.bioController,
    this.phoneController,
    this.phoneFieldKey,
    this.phoneDialCode,
    this.phoneCountryCode,
    this.onNameTap,
    this.onNameChanged,
    this.onNameTapOutside,
    this.onBioTap,
    this.onBioChanged,
    this.onBioTapOutside,
    this.onPhoneTap,
    this.onPhoneChanged,
    this.onPhoneCountryChanged,
    this.onPhoneTapOutside,
    this.onPhotoTap,
    this.onCall,
    this.onText,
  });

  final String name;
  final String? photoUrl;
  final File? localFile;
  final String? svg;
  final String? bio;
  final String? phone;
  final String? email;
  final bool editingName;
  final bool editingBio;
  final bool editingPhone;
  final TextEditingController? nameController;
  final TextEditingController? bioController;
  final TextEditingController? phoneController;
  final GlobalKey<PhoneCountryFieldState>? phoneFieldKey;
  final String? phoneDialCode;
  final String? phoneCountryCode;
  final VoidCallback? onNameTap;
  final ValueChanged<String>? onNameChanged;
  final VoidCallback? onNameTapOutside;
  final VoidCallback? onBioTap;
  final ValueChanged<String>? onBioChanged;
  final VoidCallback? onBioTapOutside;
  final VoidCallback? onPhoneTap;
  final ValueChanged<String>? onPhoneChanged;
  final VoidCallback? onPhoneCountryChanged;
  final VoidCallback? onPhoneTapOutside;
  final VoidCallback? onPhotoTap;
  final VoidCallback? onCall;
  final VoidCallback? onText;

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
        6.height,
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
        14.height,
        if (editingPhone && phoneController != null && phoneFieldKey != null)
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
            emptyLabel: AppConstant.addPhone,
            onTap: onPhoneTap,
          ),
        4.height,
        _ContactLine(value: email, emptyLabel: 'No email'),
        20.height,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PillButton(
              label: AppConstant.call,
              icon: AppIcons.phone,
              filled: true,
              onTap: onCall,
            ),
            12.width,
            PillButton(
              label: AppConstant.text,
              icon: AppIcons.chat,
              filled: false,
              onTap: onText,
            ),
          ],
        ),
      ],
    );
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
    final display = !hasValue ? emptyLabel : raw;

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
