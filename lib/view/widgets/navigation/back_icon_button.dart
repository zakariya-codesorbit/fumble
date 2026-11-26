import 'package:flutter/material.dart';

import 'package:fumble/core/navigation/router_navigator.dart';
import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';

class BackIconButton extends StatelessWidget {
  const BackIconButton({super.key, this.onTap, this.color, this.icon});

  final VoidCallback? onTap;
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? AppColors.primary;
    return IconButton(
      onPressed: onTap ?? pop,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints.tightFor(width: 40.w, height: 40.w),
      icon: Container(
        width: 34.w,
        height: 34.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: tint, width: 1.2),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon ?? Icons.arrow_back_rounded,
          size: 18.w,
          color: tint,
        ),
      ),
    );
  }
}
