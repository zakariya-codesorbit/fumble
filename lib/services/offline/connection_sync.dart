import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../data/repositories/connection_repository.dart';
import '../network/connection_manager.dart';

/// Retries local connections that are not yet synced.
///
/// Runs when the app starts, returns to the foreground, or connectivity
/// changes from offline to online.
class ConnectionSync with WidgetsBindingObserver {
  ConnectionSync({
    required ConnectionRepository repository,
    required String? Function() currentUid,
  }) : _repository = repository,
       _currentUid = currentUid;

  final ConnectionRepository _repository;
  final String? Function() _currentUid;
  StreamSubscription<bool>? _connectivitySub;

  void start() {
    WidgetsBinding.instance.removeObserver(this);
    WidgetsBinding.instance.addObserver(this);
    _connectivitySub?.cancel();
    _connectivitySub = ConnectionManager().connectionStream.listen((online) {
      if (online) kick();
    });
    kick();
  }

  void kick() {
    final uid = _currentUid();
    if (uid == null || uid.isEmpty) return;
    unawaited(_repository.syncWithCloud(uid));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) kick();
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySub?.cancel();
  }
}
