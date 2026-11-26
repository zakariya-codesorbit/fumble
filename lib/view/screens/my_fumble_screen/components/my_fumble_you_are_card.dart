import 'package:flutter/material.dart';

import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/data/models/user_profile.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/screens/my_fumble_screen/components/my_fumble_group_card.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';

/// Gender selector card — YOU ARE / MALE · FEMALE.
class MyFumbleYouAreCard extends StatelessWidget {
  const MyFumbleYouAreCard({
    super.key,
    required this.gender,
    required this.onChanged,
  });

  final String? gender;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return MyFumbleGroupCard(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppConstant.youAreLabel.toText(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: AppStyle.w600,
            letterSpacing: 1.4,
          ),
          14.height,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: AppColors.border, width: 1.2),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _GenderChip(
                    label: AppConstant.genderMale,
                    selected: gender == UserProfile.genderMale,
                    onTap: () => onChanged(UserProfile.genderMale),
                  ),
                ),
                Expanded(
                  child: _GenderChip(
                    label: AppConstant.genderFemale,
                    selected: gender == UserProfile.genderFemale,
                    onTap: () => onChanged(UserProfile.genderFemale),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GenderChip extends StatelessWidget {
  const _GenderChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.surfaceElevated : AppColors.clear,
      borderRadius: BorderRadius.circular(AppStyle.radiusPill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppStyle.radiusPill),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: label.toText(
            color: selected ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: AppStyle.w600,
            letterSpacing: 1.1,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
