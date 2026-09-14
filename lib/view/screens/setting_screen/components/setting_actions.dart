import 'package:flutter/material.dart';

import 'package:fumble/utils/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/buttons/primary_button.dart';
import 'package:fumble/view/widgets/buttons/secondary_button.dart';
import 'package:fumble/view/widgets/dialogs/app_bottom_sheet.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';

abstract final class SettingActions {
  SettingActions._();

  static Future<void> showConfirmSheet({
    required BuildContext context,
    required String title,
    required String description,
    required String primaryCta,
    required VoidCallback onPrimaryTap,
    required bool destructive,
    Widget? body,
  }) async {
    await showAppBottomSheet<void>(
      context: context,
      title: title,
      builder: (sheetContext) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            description.toText(
              color: AppColors.secondaryText,
              fontSize: 13,
              fontWeight: AppStyle.w500,
              maxLine: 4,
            ),
            if (body != null) ...[
              16.height,
              body,
            ],
            25.height,
            PrimaryButton(
              buttonName: primaryCta,
              buttonColor: destructive ? AppColors.error : AppColors.gold,
              borderColor: destructive ? AppColors.error : AppColors.gold,
              buttonTextColor:
                  destructive ? AppColors.white : AppColors.background,
              onPressed: () {
                Navigator.pop(sheetContext);
                onPrimaryTap();
              },
            ),
            8.height,
            SecondaryButton(
              buttonName: AppConstant.cancel,
              buttonColor: AppColors.white.withValues(alpha: 0.06),
              borderColor: AppColors.white.withValues(alpha: 0.06),
              buttonTextColor: AppColors.primaryText,
              fontWeight: AppStyle.w600,
              onPressed: () => Navigator.pop(sheetContext),
            ),
            8.height,
          ],
        );
      },
    );
  }
}
