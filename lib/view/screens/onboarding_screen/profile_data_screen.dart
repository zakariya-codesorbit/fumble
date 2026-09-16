import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/core/navigation/onboarding_gate.dart';
import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/view/screens/onboarding_screen/components/onboarding_layout.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/inputs/custom_text_field.dart';

class ProfileDataScreen extends ConsumerStatefulWidget {
  const ProfileDataScreen({super.key});

  @override
  ConsumerState<ProfileDataScreen> createState() => _ProfileDataScreenState();
}

class _ProfileDataScreenState extends ConsumerState<ProfileDataScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bio = TextEditingController();
  final _aboutMe = TextEditingController();
  final _location = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _bio.dispose();
    _aboutMe.dispose();
    _location.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentUserProfileProvider).valueOrNull;
    final actions = ref.read(onboardingNotifierProvider.notifier);

    if (profile != null && !_initialized) {
      _bio.text = profile.bio ?? '';
      _aboutMe.text = profile.aboutMe ?? '';
      _location.text = profile.location ?? '';
      _initialized = true;
    }

    void submit() => actions.saveDetailsAndContinue(
          formKey: _formKey,
          bio: _bio.text,
          aboutMe: _aboutMe.text,
          location: _location.text,
        );

    return OnboardingLayout(
      title: AppConstant.onboardingDataTitle,
      subtitle: AppConstant.onboardingDataSubtitle,
      currentStep: OnboardingGate.dataStep,
      cta: AppConstant.onboardingFinish,
      formKey: _formKey,
      onContinue: submit,
      child: Column(
        children: [
          CustomTextField(
            controller: _bio,
            label: AppConstant.bioLabel,
            hintText: AppConstant.bioHint,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.next,
            maxLine: 2,
            validator: (value) {
              if (value == null || value.isBlank) {
                return AppConstant.bioRequired;
              }
              return null;
            },
          ),
          16.height,
          CustomTextField(
            controller: _aboutMe,
            label: AppConstant.aboutMeLabel,
            hintText: AppConstant.aboutMeHint,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.next,
            maxLine: 4,
            validator: (value) {
              if (value == null || value.isBlank) {
                return AppConstant.aboutMeRequired;
              }
              return null;
            },
          ),
          16.height,
          CustomTextField(
            controller: _location,
            label: AppConstant.locationLabel,
            hintText: AppConstant.locationHint,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.addressCity],
            onSubmitted: (_) => submit(),
            validator: (value) {
              if (value == null || value.isBlank) {
                return AppConstant.locationRequired;
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
