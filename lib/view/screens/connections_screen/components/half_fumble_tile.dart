import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/data/models/half_fumble.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/layout/profile_avatar.dart';

class HalfFumbleTile extends StatelessWidget {
  const HalfFumbleTile({
    super.key,
    required this.halfFumble,
    this.onTap,
    this.onResend,
    this.onCancel,
  });

  final HalfFumble halfFumble;
  final VoidCallback? onTap;
  final VoidCallback? onResend;
  final VoidCallback? onCancel;

  String? get _statusText {
    switch (halfFumble.status) {
      case HalfFumbleStatus.invitationSent:
        return null;
      case HalfFumbleStatus.pendingAcceptance:
        return AppConstant.pendingAcceptanceLabel;
      case HalfFumbleStatus.declined:
        return 'Declined';
      case HalfFumbleStatus.expired:
        return 'Expired';
      case HalfFumbleStatus.revoked:
        return 'Cancelled';
      case HalfFumbleStatus.fumbled:
        return AppConstant.connectionsTabFumbled;
      case HalfFumbleStatus.halfFumble:
        return AppConstant.halfFumbleStatusLabel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final meeting = halfFumble.meetingDate != null
        ? DateFormat('d MMMM yyyy').format(halfFumble.meetingDate!)
        : null;
    final place = halfFumble.meetingLocation?.trim();

    return Material(
      color: AppColors.navBar,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ProfileAvatar(
                    photoUrl: halfFumble.photoUrl,
                    name: halfFumble.name,
                    size: 48,
                  ),
                  12.width,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        halfFumble.name.toText(
                          fontSize: 16,
                          fontWeight: AppStyle.w600,
                          color: AppColors.white,
                          maxLine: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        4.height,
                        halfFumble.email.toText(
                          fontSize: 13,
                          color: AppColors.softGray,
                          maxLine: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (_statusText != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: AppColors.goldMuted.withValues(alpha: 0.5),
                        ),
                      ),
                      child: _statusText!.toText(
                        fontSize: 10,
                        fontWeight: AppStyle.w600,
                        color: AppColors.gold,
                        letterSpacing: 0.4,
                      ),
                    ),
                ],
              ),
              if (meeting != null || (place != null && place.isNotEmpty)) ...[
                10.height,
                (place != null && place.isNotEmpty
                        ? (meeting != null ? '$meeting · $place' : place)
                        : meeting!)
                    .toText(
                  fontSize: 12,
                  color: AppColors.tertiaryText,
                ),
              ],
              if (halfFumble.status.canResend || halfFumble.status.canCancel) ...[
                12.height,
                Row(
                  children: [
                    if (halfFumble.status.canResend)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onResend,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.gold,
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: AppConstant.resendFumble.toText(
                            fontSize: 12,
                            fontWeight: AppStyle.w600,
                            color: AppColors.gold,
                          ),
                        ),
                      ),
                    if (halfFumble.status.canResend &&
                        halfFumble.status.canCancel)
                      8.width,
                    if (halfFumble.status.canCancel)
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
                          child: AppConstant.cancelFumble.toText(
                            fontSize: 12,
                            fontWeight: AppStyle.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
