import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/state/notifiers/auth_notifier.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/screens/setting_screen/components/setting_actions.dart';
import 'package:fumble/view/widgets/buttons/primary_button.dart';
import 'package:fumble/view/widgets/buttons/secondary_button.dart';
import 'package:fumble/utils/focus_utils.dart';
import 'package:fumble/view/widgets/dialogs/app_bottom_sheet.dart';
import 'package:fumble/view/widgets/dialogs/loading_dialog.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
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
    final password = await showAppBottomSheet<String>(
      context: context,
      title: AppConstant.deleteAccount,
      builder: (sheetContext) => const _DeleteAccountSheetBody(),
    );
    if (password == null) return;

    await unfocusKeyboard();
    // Let the confirm sheet finish dismissing so the auth loader can present.
    await Future<void>.delayed(const Duration(milliseconds: 200));
    showLoadingDialog(message: AppConstant.loading);
    try {
      await ref.read(authNotifierProvider.notifier).deleteAccount(
            password: password,
            manageLoading: false,
          );
    } finally {
      hideLoadingDialog();
    }
  }
}

/// Owns the password controller for the sheet lifetime so it is not disposed
/// while the dismiss animation is still rebuilding the field.
class _DeleteAccountSheetBody extends StatefulWidget {
  const _DeleteAccountSheetBody();

  @override
  State<_DeleteAccountSheetBody> createState() =>
      _DeleteAccountSheetBodyState();
}

class _DeleteAccountSheetBodyState extends State<_DeleteAccountSheetBody> {
  late final TextEditingController _password;

  @override
  void initState() {
    super.initState();
    _password = TextEditingController();
  }

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  void _confirm() {
    final value = _password.text;
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppConstant.deleteAccountConfirm.toText(
            color: AppColors.secondaryText,
            fontSize: 13,
            fontWeight: AppStyle.w500,
            maxLine: 4,
          ),
          16.height,
          CustomTextField(
            controller: _password,
            label: AppConstant.passwordLabel,
            hintText: AppConstant.passwordHint,
            isPassword: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _confirm(),
          ),
          25.height,
          PrimaryButton(
            buttonName: AppConstant.delete,
            buttonColor: AppColors.error,
            borderColor: AppColors.error,
            buttonTextColor: AppColors.white,
            onPressed: _confirm,
          ),
          8.height,
          SecondaryButton(
            buttonName: AppConstant.cancel,
            buttonColor: AppColors.white.withValues(alpha: 0.06),
            borderColor: AppColors.white.withValues(alpha: 0.06),
            buttonTextColor: AppColors.primaryText,
            fontWeight: AppStyle.w600,
            onPressed: () => Navigator.pop(context),
          ),
          8.height,
        ],
      ),
    );
  }
}

final settingNotifierProvider =
    NotifierProvider<SettingNotifier, SettingState>(SettingNotifier.new);
