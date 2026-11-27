import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/data/models/half_fumble.dart';
import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/screens/connections_screen/components/connection_ai_memory_banner.dart';
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
    this.aiImageUrl,
    this.aiImageAsset = AppIcons.aiPlaceholder,
  });

  final HalfFumble halfFumble;
  final VoidCallback? onTap;
  final VoidCallback? onResend;
  final VoidCallback? onCancel;
  final String? aiImageUrl;
  final String? aiImageAsset;

  String get _statusText {
    switch (halfFumble.status) {
      case HalfFumbleStatus.declined:
        return 'Declined';
      case HalfFumbleStatus.expired:
        return 'Expired';
      case HalfFumbleStatus.revoked:
        return 'Cancelled';
      case HalfFumbleStatus.fumbled:
        return AppConstant.connectionsTabFumbled;
      case HalfFumbleStatus.pendingAcceptance:
      case HalfFumbleStatus.invitationSent:
      case HalfFumbleStatus.halfFumble:
        return AppConstant.youWantToFumble(halfFumble.firstName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final moment = halfFumble.meetingDate ?? halfFumble.createdAt;
    final date = DateFormat('d MMMM yyyy').format(moment);
    final time = DateFormat('HH:mm').format(moment);
    final place = halfFumble.meetingLocation?.trim();
    final placeLabel =
        (place != null && place.isNotEmpty) ? place : AppConstant.fumbleLocationNotSet;
    final note = halfFumble.personalNote?.trim() ?? '';
    final status = _statusText.toUpperCase();

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConnectionAiMemoryBanner(
                imageUrl: aiImageUrl,
                assetPath: aiImageAsset,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProfileAvatar(
                          photoUrl: halfFumble.photoUrl,
                          name: halfFumble.name,
                          size: 45.w,
                        ),
                        10.width,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              halfFumble.name.toText(
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
                      10.height,
                      note.toText(
                        fontSize: 13,
                        fontWeight: AppStyle.w400,
                        color: AppColors.textPrimary,
                        maxLine: 3,
                        overflow: TextOverflow.ellipsis,
                        lineHeight: 1.35,
                      ),
                    ],
                    if (halfFumble.status.canResend ||
                        halfFumble.status.canCancel) ...[
                      12.height,
                      Row(
                        children: [
                          if (halfFumble.status.canResend)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: onResend,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(color: AppColors.border),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: AppConstant.resendFumble.toText(
                                  fontSize: 12,
                                  fontWeight: AppStyle.w600,
                                  color: AppColors.primary,
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
            ],
          ),
        ),
      ),
    );
  }
}
