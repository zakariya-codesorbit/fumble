import 'package:flutter/material.dart';

/// Root [Navigator] attached to [MaterialApp.navigatorKey].
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final RouteObserver<PageRoute<dynamic>> routeObserver =
    RouteObserver<PageRoute<dynamic>>();
