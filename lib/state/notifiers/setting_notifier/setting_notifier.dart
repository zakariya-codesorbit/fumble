import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/state/notifiers/auth_notifier/auth_notifier.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/view/screens/setting_screen/components/setting_actions.dart';
import 'package:fumble/view/widgets/inputs/custom_text_field.dart';

class SettingState {
  const SettingState();
}

class SettingNotifier extends Notifier<SettingState> {
  @override
  SettingState build() => const SettingState();

  Future<void> logout(BuildContext context) {
    return SettingActions.showConfirmSheet(
      context: context,
      title: AppConstant.logout,
      description: AppConstant.logoutConfirm,
      primaryCta: AppConstant.logout,
      destructive: false,
      onPrimaryTap: () {
        ref.read(authNotifierProvider.notifier).logout();
      },
    );
  }

  Future<void> deleteAccount(BuildContext context) async {
    final passwordController = TextEditingController();
    try {
      await SettingActions.showConfirmSheet(
        context: context,
        title: AppConstant.deleteAccount,
        description: AppConstant.deleteAccountConfirm,
        primaryCta: AppConstant.delete,
        destructive: true,
        body: CustomTextField(
          controller: passwordController,
          label: AppConstant.passwordLabel,
          hintText: AppConstant.passwordHint,
          isPassword: true,
        ),
        onPrimaryTap: () {
          ref.read(authNotifierProvider.notifier).deleteAccount(
                password: passwordController.text,
              );
        },
      );
    } finally {
      passwordController.dispose();
    }
  }
}

final settingNotifierProvider =
    NotifierProvider<SettingNotifier, SettingState>(SettingNotifier.new);
