import 'package:flutter/material.dart';

import 'package:fumble/utils/dimension.dart';

extension IntExtension on int {
  Widget get height => SizedBox(height: widgetHeight(toDouble()));

  Widget get width => SizedBox(width: widgetWidth(toDouble()));

  double get h => widgetHeight(toDouble());

  double get w => widgetWidth(toDouble());
}
