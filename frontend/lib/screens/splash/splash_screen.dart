import 'dart:async';
import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../services/auth_service.dart';

/// Splash screen displaying MachineTrack app branding before navigating to Login.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _navigationTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        final user = AuthService().currentUser;
        if (user != null) {
          Navigator.pushReplacementNamed(context, AppRoutes.main);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      }
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBlue,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // App Logo Placeholder
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(40),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.precision_manufacturing_rounded,
                      size: 56,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                // App Name
                const Text(
                  'MachineTrack',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                // App Tagline
                Text(
                  'Real-Time Machine Inspection & Breakdown Logging',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withAlpha(200),
                    height: 1.4,
                  ),
                ),
                const Spacer(),
                // Loading indicator & footer
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Manufacturing Operations v1.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withAlpha(150),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
