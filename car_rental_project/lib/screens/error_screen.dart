import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:car_rental_project/screens/home_screen.dart';

class InternetChecker extends StatefulWidget {
  final Widget child;

  const InternetChecker({super.key, required this.child});

  @override
  _InternetCheckerState createState() => _InternetCheckerState();
}

class _InternetCheckerState extends State<InternetChecker> {
  bool _isConnected = true;
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
  }

  // Initial connectivity check and listen for changes
  Future<void> _initializeConnectivity() async {
    try {
      // Perform the initial check asynchronously
      final List<ConnectivityResult> result = await Connectivity().checkConnectivity();
      _updateConnectionStatus(result);

      // Subscribe to the connectivity changes
      _subscription = Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
    } catch (e) {
      debugPrint('Connectivity error: $e');
      setState(() {
        _isConnected = false;
      });
    }
  }

  // Update the connectivity status
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    setState(() {
      // Consider connected if any result is not 'none'
      _isConnected = results.any((result) => result != ConnectivityResult.none);
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: _isConnected 
          ? widget.child 
          : const NoInternetScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 100, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              'No Internet Connection',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Please check your network settings and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final results = await Connectivity().checkConnectivity();
                if (results.any((result) => result != ConnectivityResult.none)) {
                  if (context.mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                    );
                  }
                }
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

