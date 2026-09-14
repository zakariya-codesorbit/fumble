import 'package:flutter/material.dart';

import 'package:fumble/utils/colors.dart';

extension WidgetExtension on Widget {
  Widget onPress(VoidCallback onTap, {VoidCallback? onLongPress}) => InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        splashColor: AppColors.clear,
        highlightColor: AppColors.clear,
        child: this,
      );

  Widget get center => Center(child: this);

  Widget get centerRight =>
      Align(alignment: Alignment.centerRight, child: this);

  Widget get centerLeft => Align(alignment: Alignment.centerLeft, child: this);

  Widget get topCenter => Align(alignment: Alignment.topCenter, child: this);

  Widget get bottomCenter =>
      Align(alignment: Alignment.bottomCenter, child: this);

  Widget get bottomLeft => Align(alignment: Alignment.bottomLeft, child: this);

  Widget get bottomRight =>
      Align(alignment: Alignment.bottomRight, child: this);

  Widget get topRight => Align(alignment: Alignment.topRight, child: this);

  Widget get topLeft => Align(alignment: Alignment.topLeft, child: this);

  Widget get expanded => Expanded(child: this);

  Widget align(Alignment alignment) =>
      Align(alignment: alignment, child: this);

  Widget baseline(double width) => Baseline(
        baseline: width,
        baselineType: TextBaseline.alphabetic,
        child: this,
      );

  Widget rotate(int degree) => RotatedBox(
        quarterTurns: degree,
        child: this,
      );

  Widget paddingOnly({
    double top = 0,
    double bottom = 0,
    double left = 0,
    double right = 0,
  }) =>
      Padding(
        padding: EdgeInsets.only(
          top: top,
          bottom: bottom,
          left: left,
          right: right,
        ),
        child: this,
      );

  Widget paddingAll(double padding) => Padding(
        padding: EdgeInsets.all(padding),
        child: this,
      );

  Widget paddingSymmetric({double horizontal = 0, double vertical = 0}) =>
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontal,
          vertical: vertical,
        ),
        child: this,
      );

  Widget positioned({
    double top = 0,
    double bottom = 0,
    double left = 0,
    double right = 0,
  }) =>
      Positioned(
        top: top,
        bottom: bottom,
        left: left,
        right: right,
        child: this,
      );
}
