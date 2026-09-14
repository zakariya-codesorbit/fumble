import 'package:flutter/material.dart';

import 'package:fumble/utils/colors.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/navigation/back_icon_button.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.showBack = false,
    this.onBack,
    this.brandTitle = false,
    this.centerTitle = true,
  });

  final String? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBack;
  final VoidCallback? onBack;
  final bool brandTitle;
  final bool centerTitle;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: centerTitle,
      leading: leading ?? (showBack ? BackIconButton(onTap: onBack) : null),
      automaticallyImplyLeading: leading != null || showBack,
      title: title?.toText(
              color: brandTitle ? AppColors.gold : AppColors.white,
              fontSize: brandTitle ? 18 : 20,
              fontWeight: brandTitle ? AppStyle.w700 : AppStyle.w600,
              letterSpacing: brandTitle ? 3 : 0,
            ),
      actions: actions,
    );
  }
}
