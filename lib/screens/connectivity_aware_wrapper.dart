import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/providers/connectivity_provider.dart';

class ConnectivityAwareWrapper extends ConsumerWidget {
  final Widget child;
  const ConnectivityAwareWrapper({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityStatus = ref.watch(connectivityProvider);
    
    // Check if the device is connected to the internet.
    // We safely access the value, defaulting to 'true' if the stream hasn't emitted yet.
    final bool isConnected = connectivityStatus.when(
      data: (result) => result != ConnectivityResult.none,
      loading: () => true, // Assume connected while loading
      error: (_, __) => true, // Assume connected on error to avoid false positives
    );

    return Stack(
      children: [
        // This is your main app content (the current screen)
        child,

        // This is the animated banner that shows/hides based on connection status
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          // If connected, move the banner off-screen. If not, bring it into view.
          top: isConnected ? -60 : 0, 
          left: 0,
          right: 0,
          child: const NoInternetBanner(),
        ),
      ],
    );
  }
}

class NoInternetBanner extends StatelessWidget {
  const NoInternetBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        padding: const EdgeInsets.only(top: 10),
        color: Colors.red.shade700,
        height: 60,
        child: const SafeArea(
          bottom: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                'No Internet Connection',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}