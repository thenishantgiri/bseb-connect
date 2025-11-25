import 'package:bseb/view_controllers/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utilities/SharedPreferencesHelper.dart';
import 'LoginScreen.dart';

class AnnouncementScreen extends StatefulWidget {
  const AnnouncementScreen({super.key});

  static const Color themeColor = Color(0xFF9A1515);
  static const String bsebUrl = 'https://secondary.biharboardonline.com/';

  @override
  State<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  SharedPreferencesHelper sharedPreferencesHelper = SharedPreferencesHelper();

  Future<void> _launchBsebUrl() async {
    final Uri uri = Uri.parse(AnnouncementScreen.bsebUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not open $uri');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadLanguage(); // call async function
  }

  Future<void> _loadLanguage() async {
    try {
      String? langCode = await sharedPreferencesHelper.getPref("lang");

      if (langCode != null && langCode.isNotEmpty) {
        Locale locale = Locale(langCode);
        Get.updateLocale(locale);
      } else {
        Get.updateLocale(const Locale("en"));
      }
    } catch (e) {
      print("Error loading language: $e");
      Get.updateLocale(const Locale("en")); // safe default
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AnnouncementScreen.themeColor, Color(0xFFd62828)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Card(
              elevation: 12,
              shadowColor: Colors.black45,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🔔 Animated Icon or Lottie (replace with your asset if available)
                    const Icon(
                      Icons.campaign_rounded,
                      size: 100,
                      color: AnnouncementScreen.themeColor,
                    ),
                    const SizedBox(height: 20),

                    // Title
                     Text(
                      "BSEB_Important_Announcement".tr,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),

                    // Description
                     Text(
                      "bseb_anouncement".tr,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 35),

                    // Primary button
                    ElevatedButton(
                      onPressed: _launchBsebUrl,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AnnouncementScreen.themeColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 6,
                      ),
                      child:  Text(
                        "View_Detailed_Schedule".tr,
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Skip button (ghost style)
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => LoginScreen()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AnnouncementScreen.themeColor, width: 1.5),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child:  Text(
                        "skip".tr,
                        style: TextStyle(
                          fontSize: 16,
                          color: AnnouncementScreen.themeColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Dummy Login/Register Page
class LoginRegisterPage extends StatelessWidget {
  const LoginRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login / Register"),
        backgroundColor: AnnouncementScreen.themeColor,
      ),
      body: const Center(
        child: Text("Login or Register here...", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
