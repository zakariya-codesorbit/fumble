import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/state/providers/app_providers.dart';
import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/utils/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/base/base_screen_widget.dart';
import 'package:fumble/view/widgets/buttons/primary_button.dart';
import 'package:fumble/view/widgets/buttons/secondary_button.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/extention/widget_extension.dart';
import 'package:fumble/view/widgets/layout/app_app_bar.dart';
import 'package:fumble/view/widgets/layout/profile_avatar.dart';
import 'package:fumble/view/widgets/navigation/back_icon_button.dart';

class FumblePreviewScreen extends ConsumerWidget {
  const FumblePreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fumble = ref.watch(fumbleNotifierProvider);
    final fumbleActions = ref.read(fumbleNotifierProvider.notifier);
    final preview = fumble.preview;

    if (preview == null) {
      return BaseScreenWidget(
        builder: (context) => ScaffoldContent(
          body: Center(
            child: PrimaryButton(
              buttonName: AppConstant.done,
              onPressed: fumbleActions.cancel,
            ),
          ),
        ),
      );
    }

    return BaseScreenWidget(
      builder: (context) => ScaffoldContent(
        appBar: AppAppBar(
          leading: BackIconButton(
            icon: AppIcons.close,
            onTap: fumbleActions.cancel,
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              AppConstant.previewTitle.toText(
                fontSize: 28,
                fontWeight: AppStyle.w700,
                lineHeight: 1.15,
              ),
              8.height,
              AppConstant.previewSubtitle.toText(
                fontSize: 14,
                color: AppColors.softGray,
                textAlign: TextAlign.center,
              ),
              36.height,
              ProfileAvatar(
                photoUrl: preview.photoUrl,
                name: preview.name,
                size: 120,
              ),
              20.height,
              preview.name.toText(
                fontSize: 20,
                fontWeight: AppStyle.w600,
              ),
              if (preview.email != null && preview.email!.isNotEmpty) ...[
                6.height,
                preview.email!.toText(
                  fontSize: 14,
                  color: AppColors.gold,
                ),
              ],
              const Spacer(),
              PrimaryButton(
                buttonName: AppConstant.confirmFumble,
                isLoading: fumble.confirming,
                onPressed: fumbleActions.confirm,
              ),
              12.height,
              SecondaryButton(
                buttonName: AppConstant.cancel,
                onPressed: fumbleActions.cancel,
              ),
              24.height,
            ],
          ).paddingSymmetric(horizontal: 28.w),
        ),
      ),
    );
  }
}
