import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/core/navigation/app_routes.dart';
import 'package:fumble/core/navigation/router_navigator.dart';
import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/utils/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/view/screens/setting_screen/components/setting_row_tile.dart';
import 'package:fumble/view/widgets/base/base_screen_widget.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/layout/app_app_bar.dart';

class SettingScreen extends ConsumerWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.read(settingNotifierProvider.notifier);

    return BaseScreenWidget(
      builder: (context) => ScaffoldContent(
        appBar: const AppAppBar(
          title: AppConstant.settings,
          showBack: true,
        ),
        body: ListView(
          padding: EdgeInsets.all(28.w),
          children: [
            SettingRowTile(
              label: AppConstant.editProfile,
              icon: AppIcons.personOutline,
              onTap: () => push(AppRoutes.editProfile),
            ),
            12.height,
            SettingRowTile(
              label: AppConstant.logout,
              icon: AppIcons.logout,
              onTap: () => settings.logout(context),
            ),
            12.height,
            SettingRowTile(
              label: AppConstant.deleteAccount,
              icon: AppIcons.deleteOutline,
              foreground: AppColors.error,
              onTap: () => settings.deleteAccount(context),
            ),
          ],
        ),
      ),
    );
  }
}
