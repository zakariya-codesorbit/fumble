import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/core/navigation/app_nav_index.dart';
import 'package:fumble/services/analytics/analytics_events.dart';
import 'package:fumble/services/analytics/analytics_service.dart';

class BottomNavState {
  const BottomNavState({this.index = AppNavIndex.flumble});
  final int index;

  BottomNavState copyWith({int? index}) =>
      BottomNavState(index: index ?? this.index);
}

class BottomNavNotifier extends Notifier<BottomNavState> {
  @override
  BottomNavState build() => const BottomNavState();

  void setIndex(int index) {
    if (index < 0 || index >= AppNavIndex.tabCount) return;
    if (index == state.index) return;
    state = state.copyWith(index: index);
    final tab = AnalyticsParams.tabNameForIndex(index);
    AnalyticsService.instance.logTabSelected(tab);
    if (index == AppNavIndex.myFlumble) {
      AnalyticsService.instance.logMyFlumbleOpened();
    } else if (index == AppNavIndex.connections) {
      AnalyticsService.instance.logConnectionsOpened();
    }
  }

  void reset() => state = const BottomNavState();
}

final bottomNavProvider =
    NotifierProvider<BottomNavNotifier, BottomNavState>(BottomNavNotifier.new);
