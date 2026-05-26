import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/routes.dart';

/// A lightweight splash/decision screen shown on app launch.
///
/// It checks:
///   1. If the user is already signed in → go to Home.
///   2. If the user has seen onboarding before → go to Login.
///   3. Otherwise → go to Onboarding.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _decide();
  }

  Future<void> _decide() async {
    // Give the widget tree a frame to settle.
    await Future.delayed(const Duration(milliseconds: 200));

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Already signed in — skip everything and go to Home.
      if (mounted) {
        Navigator.pushReplacementNamed(context, Routes.home);
      }
      return;
    }

    // Not signed in — check if onboarding was already completed.
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    if (!mounted) return;

    if (hasSeenOnboarding) {
      Navigator.pushReplacementNamed(context, Routes.login);
    } else {
      Navigator.pushReplacementNamed(context, Routes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Simple branded loading screen while the decision is made.
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 80,
              height: 80,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.devices_rounded,
                size: 60,
                color: Color(0xFF1607B8),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'B Tech',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
