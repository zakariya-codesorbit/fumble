import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:fumble/core/navigation/app_routes.dart';
import 'package:fumble/core/navigation/router_navigator.dart';
import 'package:fumble/data/models/user_profile.dart';
import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/view/widgets/feedback/custom_snackbar.dart';
import 'package:fumble/view/widgets/inputs/phone_country_field.dart';

abstract final class ProfileActions {
  ProfileActions._();

  static void openSettings() => push(AppRoutes.settings);

  static Future<void> call(String? phone) async {
    final value = phone?.trim();
    if (value == null || value.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: value);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  static Future<void> text(String? phone) async {
    final value = phone?.trim();
    if (value == null || value.isEmpty) return;
    final uri = Uri(scheme: 'sms', path: value);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  static Future<void> whatsApp(String? phone) async {
    final digits = phone?.replaceAll(RegExp(r'\D'), '') ?? '';
    if (digits.isEmpty) return;
    final uri = Uri.parse('https://wa.me/$digits');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> showPhotoSheet({
    required BuildContext context,
    required WidgetRef ref,
  }) {
    return ref.read(profileNotifierProvider.notifier).showPhotoSheet(context);
  }

  static Future<bool> save({
    required WidgetRef ref,
    required UserProfile profile,
    required String name,
    required String bio,
    required String aboutMe,
    required String location,
    required String phone,
    required String nationalPhone,
  }) async {
    if (nationalPhone.trim().isNotEmpty &&
        !PhoneCountryField.isValidNational(nationalPhone)) {
      showAppToast(AppConstant.phoneInvalid, isError: true);
      return false;
    }

    await ref.read(profileNotifierProvider.notifier).save(
          name: name,
          bio: bio,
          aboutMe: aboutMe,
          location: location,
          phone: phone,
          sharePhone: profile.sharePhone,
          shareEmail: profile.shareEmail,
        );
    return true;
  }

  static void resetEdit(WidgetRef ref) {
    ref.read(profileNotifierProvider.notifier).resetEdit();
  }

  static void retryLoad(WidgetRef ref) {
    ref.invalidate(currentUserProfileProvider);
  }
}
