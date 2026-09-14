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

class FumbleSuccessScreen extends ConsumerWidget {
  const FumbleSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fumble = ref.read(fumbleNotifierProvider.notifier);

    return BaseScreenWidget(
      builder: (context) => ScaffoldContent(
        body: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold, width: 1.5),
                ),
                child: const Icon(
                  AppIcons.check,
                  color: AppColors.gold,
                  size: 40,
                ),
              ),
              28.height,
              AppConstant.successTitle.toText(
                fontSize: 28,
                fontWeight: AppStyle.w700,
                lineHeight: 1.15,
              ),
              8.height,
              AppConstant.successBody.toText(
                fontSize: 14,
                color: AppColors.softGray,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              PrimaryButton(
                buttonName: AppConstant.viewConnections,
                onPressed: () => fumble.finish(openConnections: true),
              ),
              12.height,
              SecondaryButton(
                buttonName: AppConstant.done,
                onPressed: () => fumble.finish(openConnections: false),
              ),
              24.height,
            ],
          ).paddingSymmetric(horizontal: 28.w),
        ),
      ),
    );
  }
}
