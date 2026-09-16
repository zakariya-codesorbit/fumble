import 'package:flutter/material.dart';

import 'package:fumble/utils/colors.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/extention/widget_extension.dart';
import 'package:fumble/view/widgets/navigation/back_icon_button.dart';

class TopView extends StatelessWidget {
  const TopView({
    super.key,
    required this.title,
    required this.subtitle,
    this.showBack = false,
    this.onBack,
    this.topSpacing = 50,
    this.titleSubtitleGap = 8,
    this.bottomSpacing,
  });

  final String title;
  final String subtitle;
  final bool showBack;
  final VoidCallback? onBack;
  final int topSpacing;
  final int titleSubtitleGap;
  final int? bottomSpacing;

  @override
  Widget build(BuildContext context) {
    final afterSubtitle = bottomSpacing ?? (showBack ? 32 : 50);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showBack)
          BackIconButton(onTap: onBack).paddingOnly(bottom: 25.h)
        else
          topSpacing.height, 
        title.toText(
          fontSize: 28,
          fontWeight: AppStyle.w700,
          lineHeight: 1.15,
        ),
        titleSubtitleGap.height,
        subtitle.toText(
          fontSize: 14,
          color: AppColors.softGray,
        ),
        afterSubtitle.height,
      ],
    );
  }
}
