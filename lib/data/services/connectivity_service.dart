import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final _controller = StreamController<bool>.broadcast();

  Stream<bool> get onConnectivityChanged => _controller.stream;

  ConnectivityService() {
    _connectivity.onConnectivityChanged.listen((results) {
      final isConnected = results.any((result) =>
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet);
      _controller.add(isConnected);
    });
  }

  Future<bool> checkIsConnected() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((result) =>
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet);
  }

  void dispose() {
    _controller.close();
  }
}
