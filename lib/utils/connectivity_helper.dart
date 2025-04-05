import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityHelper {
  static final ConnectivityHelper _instance = ConnectivityHelper._internal();
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _subscription;
  bool _isConnected = false;

  factory ConnectivityHelper() {
    return _instance;
  }

  ConnectivityHelper._internal();

  bool get isConnected => _isConnected;

  Future<void> initialize() async {
    await checkConnectivity();
    _subscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  Future<void> checkConnectivity() async {
    ConnectivityResult result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    _isConnected = (result != ConnectivityResult.none);
  }

  void dispose() {
    _subscription?.cancel();
  }
}
