import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Tells the app whether the phone is online, and notifies when it changes.
class ConnectivityService extends ChangeNotifier {
  final _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _online = true;

  bool get isOnline => _online;

  Future<void> init() async {
    _subscription = _connectivity.onConnectivityChanged.listen(_update);
    try {
      _update(await _connectivity.checkConnectivity());
    } catch (_) {
      // Assume online; requests will fail and be retried if not.
    }
  }

  void _update(List<ConnectivityResult> results) =>
      setOnline(results.any((r) => r != ConnectivityResult.none));

  @visibleForTesting
  void setOnline(bool value) {
    if (value == _online) return;
    _online = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
