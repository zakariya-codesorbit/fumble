import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/core/navigation/onboarding_gate.dart';
import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/utils/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/screens/onboarding_screen/components/onboarding_layout.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/extention/widget_extension.dart';
import 'package:fumble/view/widgets/layout/profile_avatar.dart';

class UploadPhotoScreen extends ConsumerWidget {
  const UploadPhotoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentUserProfileProvider).valueOrNull;
    final onboarding = ref.watch(onboardingNotifierProvider);
    final actions = ref.read(onboardingNotifierProvider.notifier);

    return OnboardingLayout(
      title: AppConstant.onboardingPhotoTitle,
      subtitle: AppConstant.onboardingPhotoSubtitle,
      currentStep: OnboardingGate.photoStep,
      onContinue: actions.savePhotoAndContinue,
      child: Column(
        children: [
          30.height,
          ProfileAvatar(
            photoUrl: profile?.photoUrl,
            localFile: onboarding.localPhoto,
            name: profile?.name,
            size: 140,
            onTap: actions.pickPhoto,
          ).center,
          25.height,
          AppConstant.onboardingPhotoHint
              .toText(
                color: AppColors.gold,
                fontSize: 13,
                fontWeight: AppStyle.w500,
                textAlign: TextAlign.center,
              )
              .onPress(actions.pickPhoto)
              .center,
        ],
      ),
    );
  }
}
