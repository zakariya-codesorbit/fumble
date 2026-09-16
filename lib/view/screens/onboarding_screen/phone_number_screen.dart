import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/core/navigation/onboarding_gate.dart';
import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/view/screens/onboarding_screen/components/onboarding_layout.dart';
import 'package:fumble/view/widgets/inputs/custom_text_field.dart';

class PhoneNumberScreen extends ConsumerStatefulWidget {
  const PhoneNumberScreen({super.key});

  @override
  ConsumerState<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends ConsumerState<PhoneNumberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentUserProfileProvider).valueOrNull;
    final actions = ref.read(onboardingNotifierProvider.notifier);

    if (profile != null && !_initialized) {
      _phone.text = profile.phone ?? '';
      _initialized = true;
    }

    void submit() => actions.savePhoneAndContinue(
          formKey: _formKey,
          phone: _phone.text,
        );

    return OnboardingLayout(
      title: AppConstant.onboardingPhoneTitle,
      subtitle: AppConstant.onboardingPhoneSubtitle,
      currentStep: OnboardingGate.phoneStep,
      formKey: _formKey,
      onContinue: submit,
      child: BasePhoneField(
        controller: _phone,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => submit(),
      ),
    );
  }
}
