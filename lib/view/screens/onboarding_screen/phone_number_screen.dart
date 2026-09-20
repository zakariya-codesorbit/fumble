import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/core/navigation/onboarding_gate.dart';
import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/view/screens/onboarding_screen/components/onboarding_layout.dart';
import 'package:fumble/view/widgets/inputs/phone_country_field.dart';

class PhoneNumberScreen extends ConsumerStatefulWidget {
  const PhoneNumberScreen({super.key});

  @override
  ConsumerState<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends ConsumerState<PhoneNumberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneFieldKey = GlobalKey<PhoneCountryFieldState>();
  final _phone = TextEditingController();
  String _initialDialCode = '+1';
  String _initialCountryCode = 'US';
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
      final parsed = PhoneCountryField.parseStored(profile.phone);
      _initialDialCode = parsed.dialCode;
      _initialCountryCode = parsed.countryCode;
      _phone.text = parsed.national;
      _initialized = true;
    }

    void submit() {
      final full = _phoneFieldKey.currentState?.fullNumber ??
          PhoneCountryField.formatFull(
            dialCode: _initialDialCode,
            national: _phone.text,
          );
      actions.savePhoneAndContinue(
        formKey: _formKey,
        phone: full,
      );
    }

    return OnboardingLayout(
      title: AppConstant.onboardingPhoneTitle,
      subtitle: AppConstant.onboardingPhoneSubtitle,
      currentStep: OnboardingGate.phoneStep,
      cta: AppConstant.onboardingFinish,
      formKey: _formKey,
      onContinue: submit,
      child: PhoneCountryField(
        key: _phoneFieldKey,
        controller: _phone,
        initialDialCode: _initialDialCode,
        initialCountryCode: _initialCountryCode,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => submit(),
      ),
    );
  }
}
