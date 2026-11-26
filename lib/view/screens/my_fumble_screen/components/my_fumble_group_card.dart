import 'package:flutter/material.dart';

import 'package:fumble/core/theme/colors.dart';

/// Shared gold-bordered card used by My Fumble groups (g1 / g3 / g4).
class MyFumbleGroupCard extends StatelessWidget {
  const MyFumbleGroupCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 20, 20, 20),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      child: child,
    );
  }
}
