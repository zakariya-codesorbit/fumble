import 'package:flutter/material.dart';

import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';

/// Outlined gold "Record Memory" control on the fumble preview.
class FumblePreviewRecordMemory extends StatelessWidget {
  const FumblePreviewRecordMemory({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.clear,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.goldMuted, width: 0.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(AppIcons.mic, size: 22, color: AppColors.gold),
              10.width,
              AppConstant.recordMemory.toText(
                color: AppColors.gold,
                fontSize: 16,
                fontWeight: AppStyle.w700,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
