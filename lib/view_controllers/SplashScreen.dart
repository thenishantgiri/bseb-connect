import 'package:bseb/view_controllers/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../utilities/CustomColors.dart';
import '../utilities/SharedPreferencesHelper.dart';
import 'AnnouncementScreen.dart';
import 'LoginScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Reduced delay for faster startup - SharedPreferences is already initialized
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // Use sync getter since SharedPreferences is already initialized in main()
    final sharedPrefs = SharedPreferencesHelper();
    final isLoggedIn = sharedPrefs.getBool('isLoggedIn') ?? false;

    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Homescreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AnnouncementScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(CustomColors.theme_orange),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Image.asset(
              'assets/images/app_logo.png',
              width: 150,
              height: 150,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.school,
                  size: 100,
                  color: Colors.white,
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'BSEB Connect',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
