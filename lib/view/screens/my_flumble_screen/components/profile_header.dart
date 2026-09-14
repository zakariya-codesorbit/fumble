import 'package:flutter/material.dart';
import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/utils/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/screens/my_flumble_screen/components/pill_button.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/extention/widget_extension.dart';
import 'package:fumble/view/widgets/layout/profile_avatar.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.name,
    required this.photoUrl,
    required this.heading,
    required this.bio,
    required this.hasBio,
    required this.phone,
    required this.hasPhone,
    required this.onEdit,
    this.onCall,
    this.onText,
  });

  final String name;
  final String? photoUrl;
  final String heading;
  final String bio;
  final bool hasBio;
  final String phone;
  final bool hasPhone;
  final VoidCallback onEdit;
  final VoidCallback? onCall;
  final VoidCallback? onText;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        heading.toText(
          color: AppColors.gold,
          fontSize: 12,
          fontWeight: AppStyle.w600,
          letterSpacing: 1.4,
        ),
        18.height,
        ProfileAvatar(photoUrl: photoUrl, name: name, size: 128),
        18.height,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: name.toText(
                fontSize: 28,
                fontWeight: AppStyle.w700,
                textAlign: TextAlign.center,
              ),
            ),
            6.width,
            const Icon(
              AppIcons.edit,
              size: 18,
              color: AppColors.white,
            ).onPress(onEdit),
          ],
        ),
        8.height,
        bio.toText(
          color: hasBio ? AppColors.softGray : AppColors.softGrayDim,
          fontSize: 15,
          textAlign: TextAlign.center,
        ),
        10.height,
        (hasPhone ? phone : AppConstant.addPhone).toText(
          color: hasPhone ? AppColors.white : AppColors.softGrayDim,
          fontSize: 16,
          fontWeight: AppStyle.w500,
        ),
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
