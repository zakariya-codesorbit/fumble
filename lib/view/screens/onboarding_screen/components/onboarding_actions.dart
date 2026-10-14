import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/services/location/location_country_service.dart';
import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/view/widgets/inputs/phone_country_field.dart';

class ResolvedPhoneCountry {
  const ResolvedPhoneCountry({
    required this.dialCode,
    required this.countryCode,
  });

  final String dialCode;
  final String countryCode;
}

abstract final class OnboardingActions {
  OnboardingActions._();

  static Future<void> showPhotoSheet({
    required BuildContext context,
    required WidgetRef ref,
  }) {
    return ref
        .read(onboardingNotifierProvider.notifier)
        .showPhotoSheet(context);
  }

  static Future<void> savePhotoAndContinue(WidgetRef ref) {
    return ref.read(onboardingNotifierProvider.notifier).savePhotoAndContinue();
  }

  static Future<void> savePhoneAndContinue({
    required WidgetRef ref,
    required GlobalKey<FormState> formKey,
    required String phone,
  }) {
    return ref.read(onboardingNotifierProvider.notifier).savePhoneAndContinue(
          formKey: formKey,
          phone: phone,
        );
  }

  /// Returns a country from device location when the profile has no phone yet.
  static Future<ResolvedPhoneCountry?> resolveCountryFromLocation(
    WidgetRef ref,
  ) async {
    final profile = ref.read(currentUserProfileProvider).valueOrNull;
    if (profile != null && (profile.phone?.trim().isNotEmpty ?? false)) {
      return null;
    }

    final resolved = await LocationCountryService.resolveFromDeviceLocation();
    if (resolved == null) return null;
    return ResolvedPhoneCountry(
      dialCode: resolved.dialCode,
      countryCode: resolved.countryCode,
    );
  }

  static String formatPhone({
    required String national,
    required String dialCode,
    required PhoneCountryFieldState? fieldState,
  }) {
    final trimmed = national.trim();
    if (trimmed.isEmpty) return '';
    return fieldState?.fullNumber ??
        PhoneCountryField.formatFull(dialCode: dialCode, national: trimmed);
  }
}
