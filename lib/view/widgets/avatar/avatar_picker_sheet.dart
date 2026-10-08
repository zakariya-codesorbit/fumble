import 'package:flutter/material.dart';

import 'package:fumble/utils/app_avatars.dart';
import 'package:fumble/utils/avatar_svg.dart';
import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/view/widgets/dialogs/app_bottom_sheet.dart';
import 'package:fumble/view/widgets/extention/widget_extension.dart';

/// Circular grid of bundled avatars. Pops the selected asset path.
Future<String?> showAvatarPickerSheet(BuildContext context) {
  return showAppBottomSheet<String>(
    context: context,
    title: AppConstant.avatars,
    builder: (sheetContext) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: AppAvatars.all.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        itemBuilder: (context, index) {
          final path = AppAvatars.all[index];
          return GestureDetector(
            onTap: () => Navigator.pop(sheetContext, path),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              child: ClipOval(
                child: AvatarSvgPicture(asset: path),
              ).paddingAll(4),
            ),
          );
        },
      );
    },
  );
}
