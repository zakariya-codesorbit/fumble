import 'package:flutter/material.dart';

import 'package:fumble/core/navigation/onboarding_gate.dart';
import 'package:fumble/utils/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';

class OnboardingProgress extends StatelessWidget {
  const OnboardingProgress({
    super.key,
    required this.currentStep,
    this.totalSteps = OnboardingGate.totalSteps,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppConstant.onboardingStepLabel(currentStep, totalSteps).toText(
          color: AppColors.gold,
          fontSize: 14,
          fontWeight: AppStyle.w600,
          letterSpacing: 1.2,
        ),
        10.height,
        Row(
          children: List<Widget>.generate(totalSteps, (index) {
            final active = index < currentStep;
            return Expanded(
              child: Container(
                height: 4.h,
                margin: EdgeInsets.only(
                  right: index == totalSteps - 1 ? 0 : 8.w,
                ),
                decoration: BoxDecoration(
                  color: active ? AppColors.gold : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
