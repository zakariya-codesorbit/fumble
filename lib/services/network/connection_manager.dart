import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectionManager {
  static final ConnectionManager _instance = ConnectionManager._internal();
  factory ConnectionManager() => _instance;
  ConnectionManager._internal();

  final Connectivity _connectivity = Connectivity();
  bool _isConnected = true;
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  Stream<bool> get connectionStream => _connectionController.stream;
  bool get isConnected => _isConnected;

  void initialize() {
    void applyConnectivity(List<ConnectivityResult> results) {
      final hasNetwork = results.isNotEmpty &&
          results.any((result) => result != ConnectivityResult.none);
      _updateConnectionState(hasNetwork);
    }

    _connectivity.checkConnectivity().then(applyConnectivity);
    _connectivity.onConnectivityChanged.listen(applyConnectivity);
  }

  void _updateConnectionState(bool hasConnection) {
    if (_isConnected != hasConnection) {
      _isConnected = hasConnection;
      _connectionController.add(_isConnected);
    }
  }

  void dispose() {
    _connectionController.close();
  }
}
