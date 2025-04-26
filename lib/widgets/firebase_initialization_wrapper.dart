import 'package:flutter/material.dart';

/// A wrapper widget that handles Firebase initialization status
/// and shows appropriate UI based on the initialization state
class FirebaseInitializationWrapper extends StatelessWidget {
  final Widget child;
  final bool isFirebaseInitialized;
  final String? errorMessage;

  const FirebaseInitializationWrapper({
    Key? key,
    required this.child,
    required this.isFirebaseInitialized,
    this.errorMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isFirebaseInitialized) {
      return child;
    }

    // Fallback UI when Firebase fails to initialize
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.cloud_off,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Firebase Connection Issue',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  errorMessage ?? 'Unable to connect to Firebase. Please check your internet connection and try again.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Reload the page
                  Navigator.pushNamedAndRemoveUntil(
                    context, 
                    '/', 
                    (route) => false,
                  );
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
