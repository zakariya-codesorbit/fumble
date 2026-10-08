import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fumble/core/navigation/app_nav_index.dart';
import 'package:fumble/services/analytics/analytics_events.dart';
import 'package:fumble/services/analytics/analytics_service.dart';
import 'package:fumble/state/providers/service_providers.dart';

class BottomNavState {
  const BottomNavState({this.index = AppNavIndex.fumble});
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
    if (index == AppNavIndex.myfumble) {
      AnalyticsService.instance.logMyfumbleOpened();
    } else if (index == AppNavIndex.connections) {
      AnalyticsService.instance.logConnectionsOpened();
      _refreshConnections();
    }
  }

  void _refreshConnections() {
    final uid = ref.read(authServiceProvider).currentUser?.uid;
    if (uid == null || uid.isEmpty) return;
    ref.read(connectionRepositoryProvider).notifyConnectionsChanged(uid);
    ref.read(connectionSyncProvider).kick();
  }

  void reset() => state = const BottomNavState();
}

final bottomNavProvider = NotifierProvider<BottomNavNotifier, BottomNavState>(
  BottomNavNotifier.new,
);
