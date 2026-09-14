import 'package:flutter/material.dart';

import 'package:fumble/core/navigation/navigator_keys.dart';

/// Figma / design baseline.
const double kDesignHeight = 844;
const double kDesignWidth = 390;

double get screenHeight =>
    MediaQuery.of(navigatorKey.currentContext!).size.height;

double get screenWidth =>
    MediaQuery.of(navigatorKey.currentContext!).size.width;

double widgetHeight(double pixels) {
  return MediaQuery.of(navigatorKey.currentContext!).size.height /
      (kDesignHeight / pixels);
}

double widgetWidth(double pixels) {
  return MediaQuery.of(navigatorKey.currentContext!).size.width /
      (kDesignWidth / pixels);
}
