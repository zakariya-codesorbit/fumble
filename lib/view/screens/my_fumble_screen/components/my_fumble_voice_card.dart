import 'package:flutter/material.dart';

import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/screens/my_fumble_screen/components/my_fumble_group_card.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';

/// Voice-clone template card (FalAI sample) — prompt + record CTA.
class MyFumbleVoiceCard extends StatelessWidget {
  const MyFumbleVoiceCard({
    super.key,
    required this.firstName,
    required this.voiceCloneReady,
    required this.isRecording,
    required this.onRecordTap,
  });

  final String firstName;
  final bool voiceCloneReady;
  final bool isRecording;
  final VoidCallback? onRecordTap;

  @override
  Widget build(BuildContext context) {
    final displayName =
        firstName.trim().isEmpty ? AppConstant.brand : firstName.trim();
    final cta = isRecording
        ? AppConstant.recordingVoice
        : (voiceCloneReady
            ? AppConstant.voiceAlreadySaved
            : AppConstant.recordMyVoice);

    return MyFumbleGroupCard(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppConstant.yourVoiceLabel.toText(
            color: AppColors.gold,
            fontSize: 12,
            fontWeight: AppStyle.w600,
            letterSpacing: 1.4,
          ),
          14.height,
          AppConstant.voiceTemplateTitle.toText(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: AppStyle.w700,
          ),
          8.height,
          AppConstant.voiceTemplateBody.toText(
            color: AppColors.softGray,
            fontSize: 14,
            fontWeight: AppStyle.w400,
            maxLine: 5,
          ),
          14.height,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: AppConstant.voiceTemplatePrompt(displayName).toText(
              color: AppColors.softGray,
              fontSize: 14,
              fontWeight: AppStyle.w400,
              fontStyle: FontStyle.italic,
              maxLine: 8,
            ),
          ),
          16.height,
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onRecordTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.gold,
                side: const BorderSide(color: AppColors.gold, width: 1.2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppStyle.radiusPill),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isRecording ? Icons.stop_rounded : AppIcons.mic,
                    size: 18,
                    color: AppColors.gold,
                  ),
                  8.width,
                  cta.toText(
                    color: AppColors.gold,
                    fontSize: 14,
                    fontWeight: AppStyle.w600,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
