import 'package:bseb/view_controllers/HomeScreen.dart';
import 'package:flutter/material.dart';

import '../utilities/CustomColors.dart';
import '../utilities/SharedPreferencesHelper.dart';
import 'AnnouncementScreen.dart';
import 'LoginScreen.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  @override
  void initState() {
    super.initState();
    print('⏳ SplashScreen initState called');

    Future.delayed(const Duration(milliseconds: 3000), () async {
      print('⏳ SplashScreen: Checking login status...');
      final isLoggedIn = await SharedPreferencesHelper().getPref('isLoggedIn') ?? false;

      if (isLoggedIn == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Homescreen()),
            // MaterialPageRoute(builder: (_) => AnnouncementScreen())
        );
      } else {
        Navigator.pushReplacement(
          context,
          // MaterialPageRoute(builder: (_) => LoginScreen()),
          MaterialPageRoute(builder: (_) => AnnouncementScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('🎨 SplashScreen build called');
    return Container(
      color: Colors.red, // Force RED background
      child: Center(
        child: Text(
          'DEBUG MODE',
          textDirection: TextDirection.ltr,
          style: TextStyle(fontSize: 30, color: Colors.white),
        ),
      ),
    );
  }
}
