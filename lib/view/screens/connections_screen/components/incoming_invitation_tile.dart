import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/data/models/half_fumble.dart';
import 'package:fumble/utils/app_assets.dart';
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
    this.onTap,
    this.onAccept,
    this.onCancel,
    this.isBusy = false,
  });

  final HalfFumbleInvitation invitation;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onCancel;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final moment = invitation.meetingDate ?? invitation.createdAt;
    final date = DateFormat('d MMMM yyyy').format(moment);
    final time = DateFormat('HH:mm').format(moment);
    final place = invitation.meetingLocation?.trim();
    final placeLabel =
        (place != null && place.isNotEmpty) ? place : AppConstant.fumbleLocationNotSet;
    final firstName = invitation.inviterName.trim().split(RegExp(r'\s+')).first;
    final status =
        AppConstant.wantToFumbleYou(firstName.isEmpty ? invitation.inviterName : firstName)
            .toUpperCase();
    final note = invitation.personalNote?.trim() ?? '';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: Colors.transparent,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: InkWell(
              onTap: isBusy ? null : onTap,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProfileAvatar(
                          photoUrl: invitation.inviterPhotoUrl,
                          name: invitation.inviterName,
                          size: 45.w,
                        ),
                        10.width,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              invitation.inviterName.toText(
                                fontSize: 16,
                                fontWeight: AppStyle.w600,
                                maxLine: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              4.height,
                              status.toText(
                                fontSize: 11,
                                fontWeight: AppStyle.w600,
                                color: AppColors.primary,
                                letterSpacing: 0.8,
                                maxLine: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        8.width,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            date.toText(
                              fontSize: 12,
                              fontWeight: AppStyle.w500,
                              color: AppColors.textTertiary,
                            ),
                            2.height,
                            time.toText(
                              fontSize: 12,
                              fontWeight: AppStyle.w500,
                              color: AppColors.textTertiary,
                            ),
                          ],
                        ),
                      ],
                    ),
                    10.height,
                    Row(
                      children: [
                        const Icon(
                          AppIcons.location,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        6.width,
                        Expanded(
                          child: placeLabel.toText(
                            fontSize: 12,
                            fontWeight: AppStyle.w500,
                            color: AppColors.textTertiary,
                            maxLine: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (note.isNotEmpty) ...[
                      12.height,
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.border,
                      ),
                      10.height,
                      note.toText(
                        fontSize: 13,
                        fontWeight: AppStyle.w400,
                        color: AppColors.textTertiary,
                        maxLine: 3,
                        overflow: TextOverflow.ellipsis,
                        lineHeight: 1.35,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
            child: Row(
            children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isBusy ? null : onAccept,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        disabledForegroundColor:
                            AppColors.primary.withValues(alpha: 0.4),
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: AppConstant.acceptFumble.toText(
                        fontSize: 12,
                        fontWeight: AppStyle.w600,
                        color: isBusy
                            ? AppColors.primary.withValues(alpha: 0.4)
                            : AppColors.primary,
                      ),
                    ),
                  ),
                  8.width,
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isBusy ? null : onCancel,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        disabledForegroundColor:
                            AppColors.error.withValues(alpha: 0.4),
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: AppConstant.cancel.toText(
                        fontSize: 12,
                        fontWeight: AppStyle.w600,
                        color: isBusy
                            ? AppColors.error.withValues(alpha: 0.4)
                            : AppColors.error,
                      ),
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
