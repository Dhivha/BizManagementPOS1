import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../utils/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo with gold background
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.gold,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.gold.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.business_center,
                size: 100,
                color: AppTheme.primaryNavy,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'BizManagement',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppTheme.gold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your Business, Simplified',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 60),
            const SpinKitFadingCircle(
              color: AppTheme.gold,
              size: 50.0,
            ),
          ],
        ),
      ),
    );
  }
}