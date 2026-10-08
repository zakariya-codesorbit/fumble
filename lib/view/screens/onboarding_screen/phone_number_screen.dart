import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/core/navigation/onboarding_gate.dart';
import 'package:fumble/services/location/location_country_service.dart';
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
  late String _initialDialCode;
  late String _initialCountryCode;
  var _initialized = false;
  var _locationRequested = false;
  var _allowLocationOverride = true;

  @override
  void initState() {
    super.initState();
    final device = PhoneCountryField.fromDeviceLocale();
    _initialDialCode = device.dialCode;
    _initialCountryCode = device.countryCode;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_resolveCountryFromLocation());
    });
  }

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _resolveCountryFromLocation() async {
    if (!mounted || _locationRequested) return;
    _locationRequested = true;

    // Keep an existing saved phone's country; only auto-detect for empty profiles.
    final profile = ref.read(currentUserProfileProvider).valueOrNull;
    if (profile != null && (profile.phone?.trim().isNotEmpty ?? false)) {
      return;
    }

    final resolved = await LocationCountryService.resolveFromDeviceLocation();
    if (!mounted || resolved == null || !_allowLocationOverride) return;

    setState(() {
      _initialDialCode = resolved.dialCode;
      _initialCountryCode = resolved.countryCode;
    });
    _phoneFieldKey.currentState?.applyCountry(
      countryCode: resolved.countryCode,
      dialCode: resolved.dialCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentUserProfileProvider).valueOrNull;
    final actions = ref.read(onboardingNotifierProvider.notifier);

    if (profile != null && !_initialized) {
      final hasPhone = profile.phone?.trim().isNotEmpty ?? false;
      if (hasPhone) {
        final parsed = PhoneCountryField.parseStored(profile.phone);
        _initialDialCode = parsed.dialCode;
        _initialCountryCode = parsed.countryCode;
        _phone.text = parsed.national;
      }
      _initialized = true;
    }

    void submit() {
      final national = _phone.text.trim();
      final full = national.isEmpty
          ? ''
          : (_phoneFieldKey.currentState?.fullNumber ??
                PhoneCountryField.formatFull(
                  dialCode: _initialDialCode,
                  national: national,
                ));
      actions.savePhoneAndContinue(formKey: _formKey, phone: full);
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
        onCountryChanged: () => _allowLocationOverride = false,
      ),
    );
  }
}
