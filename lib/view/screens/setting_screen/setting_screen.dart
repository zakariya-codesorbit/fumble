import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/screens/setting_screen/components/setting_action_group.dart';
import 'package:fumble/view/screens/setting_screen/components/setting_actions.dart';
import 'package:fumble/view/screens/setting_screen/components/setting_toggle_group.dart';
import 'package:fumble/view/widgets/base/base_screen_widget.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/layout/app_app_bar.dart';

class SettingScreen extends ConsumerWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentUserProfileProvider).valueOrNull;
    final shareOverride = ref.watch(shareVisibilityProvider);
    final sharePhone =
        shareOverride?.sharePhone ?? profile?.sharePhone ?? true;
    final shareEmail =
        shareOverride?.shareEmail ?? profile?.shareEmail ?? true;

    return BaseScreenWidget(
      builder: (context) => ScaffoldContent(
        appBar: const AppAppBar(title: AppConstant.settings, showBack: true),
        body: ListView(
          padding: EdgeInsets.all(28.w),
          children: [
            SettingToggleGroup(
              title: AppConstant.shareContactGroup,
              items: [
                SettingToggleItem(
                  label: AppConstant.sharePhoneSetting,
                  icon: AppIcons.phone,
                  value: sharePhone,
                  onChanged: (value) => SettingActions.updateSharePhone(
                    ref: ref,
                    value: value,
                  ),
                ),
                SettingToggleItem(
                  label: AppConstant.shareEmailSetting,
                  icon: AppIcons.email,
                  value: shareEmail,
                  onChanged: (value) => SettingActions.updateShareEmail(
                    ref: ref,
                    value: value,
                  ),
                ),
              ],
            ),
            24.height,
            SettingActionGroup(
              title: AppConstant.accountGroup,
              items: [
                SettingActionItem(
                  label: AppConstant.logout,
                  icon: AppIcons.logout,
                  onTap: () => SettingActions.logout(
                    context: context,
                    ref: ref,
                  ),
                ),
                SettingActionItem(
                  label: AppConstant.deleteAccount,
                  icon: AppIcons.deleteOutline,
                  foreground: AppColors.error,
                  onTap: () => SettingActions.deleteAccount(
                    context: context,
                    ref: ref,
                  ),
                ),
              ],
            ),
            32.height,
            AppConstant.appVersionLabel.toText(
              color: AppColors.softGrayDim,
              fontSize: 12,
              fontWeight: AppStyle.w500,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
