import 'package:flutter/material.dart';

import 'package:fumble/core/navigation/router_navigator.dart';
import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/utils/colors.dart';

import '../extention/int_extension.dart';

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
    return InkWell(
      onTap: onTap ?? pop,
      child: SizedBox(
        height: 30.h,
        width: 30.w,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Icon(
            icon ?? AppIcons.back,
            size: 20,
            color: color ?? AppColors.white,
          ),
        ),
      ),
    );
  }
}
