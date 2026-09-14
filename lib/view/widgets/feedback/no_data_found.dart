import 'package:flutter/material.dart';

import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/utils/colors.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/extention/widget_extension.dart';

class NoDataFound extends StatelessWidget {
  const NoDataFound({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    this.topSpacing,
  });

  final String? title;
  final String? subtitle;
  final IconData? icon;
  final int? topSpacing;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (topSpacing != null) topSpacing!.height else const SizedBox.shrink(),
          Icon(
            icon ?? AppIcons.peopleOutline,
            size: 48,
            color: AppColors.softGrayDim,
          ),
          16.height,
          (title ?? AppConstant.dataNotFound).toText(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: AppStyle.w600,
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            8.height,
            subtitle!.toText(
              color: AppColors.softGray,
              fontSize: 14,
              fontWeight: AppStyle.w400,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ).paddingAll(32),
    );
  }
}
