import 'dart:io';

import 'package:flutter/material.dart';

import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/screens/my_fumble_screen/components/fumble_qr.dart';
import 'package:fumble/view/screens/my_fumble_screen/components/my_fumble_group_card.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/layout/profile_avatar.dart';

/// Identity card — photo actions, name, bio, phone, SCAN TO FUMBLE + QR.
class MyFumbleIdentityCard extends StatelessWidget {
  const MyFumbleIdentityCard({
    super.key,
    required this.name,
    required this.bio,
    required this.phone,
    required this.qrPayload,
    required this.fumbleCode,
    this.photoUrl,
    this.localFile,
    this.avatarAsset,
    this.onCameraTap,
    this.onAiTap,
    this.onCopyCode,
  });

  final String name;
  final String bio;
  final String? phone;
  final String qrPayload;
  final String fumbleCode;
  final String? photoUrl;
  final File? localFile;
  final String? avatarAsset;
  final VoidCallback? onCameraTap;
  final VoidCallback? onAiTap;
  final VoidCallback? onCopyCode;

  @override
  Widget build(BuildContext context) {
    final bioText = bio.trim();
    final phoneText = phone?.trim() ?? '';

    return MyFumbleGroupCard(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        children: [
          _AvatarWithActions(
            name: name,
            photoUrl: photoUrl,
            localFile: localFile,
            avatarAsset: avatarAsset,
            onCameraTap: onCameraTap,
            onAiTap: onAiTap,
          ),
          14.height,
          name.toText(
            fontSize: 28,
            fontWeight: AppStyle.w700,
            textAlign: TextAlign.center,
          ),
          if (bioText.isNotEmpty) ...[
            4.height,
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
            10.height,
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
          ] else ...[
            16.height,
            AppConstant.addPhone.toText(
              fontSize: 14,
              color: AppColors.softGrayDim,
              textAlign: TextAlign.center,
            ),
          ],
          20.height,
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          20.height,
          FumbleQr(payload: qrPayload, code: fumbleCode, onCopy: onCopyCode),
        ],
      ),
    );
  }
}

class _AvatarWithActions extends StatelessWidget {
  const _AvatarWithActions({
    required this.name,
    this.photoUrl,
    this.localFile,
    this.avatarAsset,
    this.onCameraTap,
    this.onAiTap,
  });

  final String name;
  final String? photoUrl;
  final File? localFile;
  final String? avatarAsset;
  final VoidCallback? onCameraTap;
  final VoidCallback? onAiTap;

  static const double _size = 152;
  static const double _bubble = 38;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size + 8,
      height: _size + _bubble * 0.28,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: ProfileAvatar(
              photoUrl: photoUrl,
              localFile: localFile,
              avatarAsset: avatarAsset,
              name: name,
              size: _size,
            ),
          ),
          // Icons sit on top of the profile circle.
          Positioned(
            left: 6,
            bottom: 5,
            child: _ActionBubble(
              filled: true,
              icon: AppIcons.camera,
              onTap: onCameraTap,
            ),
          ),
          Positioned(
            right: 6,
            bottom: 5,
            child: _ActionBubble(
              filled: false,
              icon: AppIcons.autoAwesome,
              onTap: onAiTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBubble extends StatelessWidget {
  const _ActionBubble({required this.filled, required this.icon, this.onTap});

  final bool filled;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      shadowColor: AppColors.black.withValues(alpha: 0.45),
      color: filled ? AppColors.gold : AppColors.background,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: filled ? AppColors.background : AppColors.gold,
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: filled ? AppColors.background : AppColors.gold,
          ),
        ),
      ),
    );
  }
}
