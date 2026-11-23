import 'package:flutter/material.dart';

import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/data/models/half_fumble.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/layout/profile_avatar.dart';

/// Inbound invitation shown to User B on the Half Fumble tab.
class IncomingInvitationTile extends StatelessWidget {
  const IncomingInvitationTile({
    super.key,
    required this.invitation,
    this.onAccept,
    this.onCancel,
  });

  final HalfFumbleInvitation invitation;
  final VoidCallback? onAccept;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.navBar,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onAccept,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.45)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ProfileAvatar(
                    photoUrl: invitation.inviterPhotoUrl,
                    name: invitation.inviterName,
                    size: 48,
                  ),
                  12.width,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        invitation.inviterName.toText(
                          fontSize: 16,
                          fontWeight: AppStyle.w600,
                          color: AppColors.white,
                          maxLine: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        4.height,
                        AppConstant.halfFumbleWantToFumbleYou.toText(
                          fontSize: 13,
                          color: AppColors.softGray,
                          maxLine: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              12.height,
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onAccept,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.gold,
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: AppConstant.acceptFumble.toText(
                        fontSize: 12,
                        fontWeight: AppStyle.w600,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                  8.width,
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: AppConstant.cancel.toText(
                        fontSize: 12,
                        fontWeight: AppStyle.w600,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
