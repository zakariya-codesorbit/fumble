import 'dart:io';

import 'package:flutter/material.dart';

import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/screens/my_fumble_screen/components/my_fumble_group_card.dart';
import 'package:fumble/view/widgets/buttons/primary_button.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/inputs/phone_country_field.dart';

/// g4 — Edit My Fumble form.
class MyFumbleEditCard extends StatelessWidget {
  const MyFumbleEditCard({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.phoneFieldKey,
    required this.phoneDialCode,
    required this.phoneCountryCode,
    required this.whatsAppController,
    required this.bioController,
    required this.onPhoneChanged,
    required this.onPhoneCountryChanged,
    required this.onChanged,
    required this.onChoosePhoto,
    required this.onSave,
    required this.isSaving,
    this.localPhoto,
    this.avatarAsset,
    this.hasExistingPhoto = false,
  });

  final TextEditingController nameController;
  final TextEditingController phoneController;
  final GlobalKey<PhoneCountryFieldState> phoneFieldKey;
  final String phoneDialCode;
  final String phoneCountryCode;
  final TextEditingController whatsAppController;
  final TextEditingController bioController;
  final ValueChanged<String> onPhoneChanged;
  final VoidCallback onPhoneCountryChanged;
  final VoidCallback onChanged;
  final VoidCallback onChoosePhoto;
  final VoidCallback? onSave;
  final bool isSaving;
  final File? localPhoto;
  final String? avatarAsset;
  final bool hasExistingPhoto;

  String get _photoLabel {
    if (localPhoto != null) {
      final name = localPhoto!.path.split(Platform.pathSeparator).last;
      return name.isEmpty ? AppConstant.changePhoto : name;
    }
    if (avatarAsset != null && avatarAsset!.trim().isNotEmpty) {
      return avatarAsset!.split('/').last;
    }
    if (hasExistingPhoto) return AppConstant.changePhoto;
    return AppConstant.noFileChosen;
  }

  @override
  Widget build(BuildContext context) {
    return MyFumbleGroupCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppConstant.editMyFumble.toText(
            fontSize: 20,
            fontWeight: AppStyle.w700,
            color: AppColors.white,
          ),
          20.height,
          _LabeledField(
            label: AppConstant.nameLabel,
            child: _EditInput(
              controller: nameController,
              hint: AppConstant.nameHint,
              onChanged: (_) => onChanged(),
            ),
          ),
          16.height,
          _LabeledField(
            label: AppConstant.phoneNumberLabel,
            child: PhoneCountryField(
              key: phoneFieldKey,
              controller: phoneController,
              initialDialCode: phoneDialCode,
              initialCountryCode: phoneCountryCode,
              textInputAction: TextInputAction.next,
              showLabel: false,
              onChanged: (value) {
                onPhoneChanged(value);
                onChanged();
              },
              onCountryChanged: onPhoneCountryChanged,
            ),
          ),
          16.height,
          _LabeledField(
            label: AppConstant.whatsAppNumberLabel,
            child: _EditInput(
              controller: whatsAppController,
              hint: AppConstant.optionalHint,
              keyboardType: TextInputType.phone,
              onChanged: (_) => onChanged(),
            ),
          ),
          16.height,
          _LabeledField(
            label: AppConstant.profilePhotoLabel,
            child: Row(
              children: [
                Material(
                  color: AppColors.primaryText,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: onChoosePhoto,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      child: AppConstant.chooseFile.toText(
                        fontSize: 13,
                        fontWeight: AppStyle.w600,
                        color: AppColors.background,
                      ),
                    ),
                  ),
                ),
                12.width,
                Expanded(
                  child: _photoLabel.toText(
                    fontSize: 13,
                    color: AppColors.softGray,
                    maxLine: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          16.height,
          _LabeledField(
            label: AppConstant.bioLabel,
            child: _EditInput(
              controller: bioController,
              hint: AppConstant.bioHint,
              maxLines: 4,
              onChanged: (_) => onChanged(),
            ),
          ),
          24.height,
          PrimaryButton(
            buttonName: AppConstant.saveProfile,
            isLoading: isSaving,
            radius: AppStyle.radiusMd,
            onPressed: onSave,
          ),
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label.toText(
          fontSize: 13,
          fontWeight: AppStyle.w500,
          color: AppColors.softGray,
        ),
        8.height,
        child,
      ],
    );
  }
}

class _EditInput extends StatelessWidget {
  const _EditInput({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      cursorColor: AppColors.gold,
      onChanged: onChanged,
      style: TextStyle(
        fontSize: 16,
        color: AppColors.white,
        fontFamily: AppStyle.fontFamily,
        fontFamilyFallback: AppStyle.fontFamilyFallback,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 14,
          color: AppColors.softGrayDim,
          fontFamily: AppStyle.fontFamily,
          fontFamilyFallback: AppStyle.fontFamilyFallback,
        ),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}
