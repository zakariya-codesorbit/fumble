import 'package:flutter/material.dart';

import 'navigator_keys.dart';

bool canPop() => Navigator.canPop(navigatorKey.currentContext!);

Future<bool> maybePop() => Navigator.maybePop(navigatorKey.currentContext!);

void pop<T extends Object?>([T? result]) =>
    Navigator.pop(navigatorKey.currentContext!, result);

void popTo(String routeName) => Navigator.popUntil(
      navigatorKey.currentContext!,
      ModalRoute.withName(routeName),
    );

Future<Object?> push(String routeName, {Object? arguments}) =>
    Navigator.pushNamed(
      navigatorKey.currentContext!,
      routeName,
      arguments: arguments,
    );

Future<Object?> replace(String routeName, {Object? arguments}) =>
    Navigator.pushReplacementNamed(
      navigatorKey.currentContext!,
      routeName,
      arguments: arguments,
    );

Future<Object?> pushAndClearAll(String routeName, {Object? arguments}) =>
    Navigator.pushNamedAndRemoveUntil(
      navigatorKey.currentContext!,
      routeName,
      (_) => false,
      arguments: arguments,
    );

void popIfPossible({VoidCallback? otherwise}) {
  if (canPop()) {
    pop();
  } else {
    otherwise?.call();
  }
}

void resetTo(String routeName, {Object? arguments}) {
  if (canPop()) {
    Navigator.popUntil(navigatorKey.currentContext!, (route) => route.isFirst);
  }
  replace(routeName, arguments: arguments);
}
