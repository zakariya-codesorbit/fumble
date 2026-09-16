import 'package:flutter/material.dart';

import 'package:fumble/utils/constant.dart';
import 'package:fumble/view/screens/auth_screen/components/top_view.dart';
import 'package:fumble/view/screens/onboarding_screen/components/onboarding_progress.dart';
import 'package:fumble/view/widgets/base/base_screen_widget.dart';
import 'package:fumble/view/widgets/buttons/primary_button.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/widget_extension.dart';

class OnboardingLayout extends StatelessWidget {
  const OnboardingLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.currentStep,
    required this.child,
    required this.onContinue,
    this.cta = AppConstant.onboardingContinue,
    this.isLoading = false,
    this.formKey,
  });

  final String title;
  final String subtitle;
  final int currentStep;
  final Widget child;
  final VoidCallback? onContinue;
  final String cta;
  final bool isLoading;
  final GlobalKey<FormState>? formKey;

  @override
  Widget build(BuildContext context) {
    final showBack = Navigator.of(context).canPop();
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TopView(
          title: title,
          subtitle: subtitle,
          showBack: showBack,
          bottomSpacing: 20,
        ),
        OnboardingProgress(currentStep: currentStep),
        28.height,
        child,
        30.height,
        PrimaryButton(
          buttonName: cta,
          isLoading: isLoading,
          onPressed: onContinue,
        ),
        24.height,
      ],
    );

    return BaseScreenWidget(
      builder: (context) => ScaffoldContent(
        body: SafeArea(
          child: SingleChildScrollView(
            child: (formKey == null
                    ? content
                    : Form(key: formKey, child: content))
                .paddingSymmetric(horizontal: 28.w),
          ),
        ),
      ),
    );
  }
}
