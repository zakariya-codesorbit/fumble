import 'package:flutter/material.dart';

import 'package:fumble/core/navigation/router_navigator.dart';
import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/utils/colors.dart';

class BackIconButton extends StatelessWidget {
  const BackIconButton({
    super.key,
    this.onTap,
    this.color,
    this.icon,
  });

  final VoidCallback? onTap;
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        icon ?? AppIcons.back,
        size: 18,
        color: color ?? AppColors.white,
      ),
      onPressed: onTap ?? pop,
    );
  }
}
