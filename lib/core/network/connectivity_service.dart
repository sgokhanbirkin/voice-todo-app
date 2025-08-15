import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Service to check internet connectivity status
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();

  /// Check if device has internet connection
  Future<bool> hasInternetConnection() async {
    try {
      // First check if device has network connectivity
      final connectivityResult = await _connectivity.checkConnectivity();

      if (connectivityResult.contains(ConnectivityResult.none)) {
        debugPrint('ConnectivityService: No network connectivity');
        return false;
      }

      // Then check if we can actually reach the internet
      try {
        final result = await InternetAddress.lookup('google.com');
        final hasInternet =
            result.isNotEmpty && result[0].rawAddress.isNotEmpty;

        debugPrint('ConnectivityService: Internet check result: $hasInternet');
        return hasInternet;
      } on SocketException {
        debugPrint('ConnectivityService: Socket exception - no internet');
        return false;
      }
    } catch (e) {
      debugPrint('ConnectivityService: Error checking connectivity: $e');
      return false;
    }
  }

  /// Stream of connectivity changes
  Stream<List<ConnectivityResult>> get connectivityStream =>
      _connectivity.onConnectivityChanged;

  /// Check if device is connected to WiFi
  Future<bool> isConnectedToWifi() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      return connectivityResults.contains(ConnectivityResult.wifi);
    } catch (e) {
      debugPrint('ConnectivityService: Error checking WiFi: $e');
      return false;
    }
  }

  /// Check if device is connected to mobile data
  Future<bool> isConnectedToMobile() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      return connectivityResults.contains(ConnectivityResult.mobile);
    } catch (e) {
      debugPrint('ConnectivityService: Error checking mobile: $e');
      return false;
    }
  }

  /// Get current connectivity status
  Future<List<ConnectivityResult>> getCurrentConnectivity() async {
    try {
      return await _connectivity.checkConnectivity();
    } catch (e) {
      debugPrint('ConnectivityService: Error getting connectivity: $e');
      return [ConnectivityResult.none];
    }
  }
}
