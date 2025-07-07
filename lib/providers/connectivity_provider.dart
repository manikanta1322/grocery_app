import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A provider that provides a stream of connectivity changes.
/// This allows the UI to reactively update when the connection status changes.
final connectivityProvider = StreamProvider<ConnectivityResult>((ref) {
  // Get the stream of connectivity changes
  final stream = Connectivity().onConnectivityChanged;

  // The stream now emits a List<ConnectivityResult>. We need to transform it.
  // We map the stream to return a single ConnectivityResult.
  return stream.map((List<ConnectivityResult> results) {
    // The device is considered offline if the list of results contains
    // only 'ConnectivityResult.none'.
    if (results.contains(ConnectivityResult.none) && results.length == 1) {
      return ConnectivityResult.none;
    } else {
      // Otherwise, the device has at least one active connection.
      // We can return the first available connection type as a representative
      // "online" state. The UI only cares if it's 'none' or not.
      return results.firstWhere(
        (result) => result != ConnectivityResult.none,
        orElse: () => ConnectivityResult.none, // Failsafe
      );
    }
  });
});