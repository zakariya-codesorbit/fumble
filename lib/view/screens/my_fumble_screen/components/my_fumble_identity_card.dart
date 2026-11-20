import 'dart:io';

import 'package:flutter/material.dart';

import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/screens/my_fumble_screen/components/my_fumble_group_card.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/layout/profile_avatar.dart';

/// g1 — photo, name, bio, phone, email (no QR / no contact actions).
class MyFumbleIdentityCard extends StatelessWidget {
  const MyFumbleIdentityCard({
    super.key,
    required this.name,
    required this.bio,
    required this.phone,
    required this.email,
    this.photoUrl,
    this.localFile,
    this.avatarAsset,
    this.onPhotoTap,
  });

  final String name;
  final String bio;
  final String? phone;
  final String email;
  final String? photoUrl;
  final File? localFile;
  final String? avatarAsset;
  final VoidCallback? onPhotoTap;

  @override
  Widget build(BuildContext context) {
    final bioText = bio.trim();
    final phoneText = phone?.trim() ?? '';
    final emailText = email.trim();

    return MyFumbleGroupCard(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        children: [
          ProfileAvatar(
            photoUrl: photoUrl,
            localFile: localFile,
            avatarAsset: avatarAsset,
            name: name,
            size: 120,
            onTap: onPhotoTap,
          ),
          16.height,
          name.toText(
            fontSize: 28,
            fontWeight: AppStyle.w700,
            textAlign: TextAlign.center,
          ),
          if (bioText.isNotEmpty) ...[
            6.height,
            bioText.toText(
              fontSize: 14,
              fontWeight: AppStyle.w500,
              color: AppColors.tertiaryText,
              textAlign: TextAlign.center,
              maxLine: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (phoneText.isNotEmpty) ...[
            16.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(AppIcons.phone, size: 16, color: AppColors.gold),
                8.width,
                phoneText.toText(
                  fontSize: 16,
                  fontWeight: AppStyle.w600,
                  color: AppColors.white,
                ),
              ],
            ),
          ],
          if (emailText.isNotEmpty) ...[
            10.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(AppIcons.email, size: 16, color: AppColors.gold),
                8.width,
                Flexible(
                  child: emailText.toText(
                    fontSize: 15,
                    fontWeight: AppStyle.w500,
                    color: AppColors.white,
                    maxLine: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          if (phoneText.isEmpty && emailText.isEmpty) ...[
            16.height,
            AppConstant.addPhone.toText(
              fontSize: 14,
              color: AppColors.softGrayDim,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
