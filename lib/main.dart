import 'package:bseb/view_controllers/SplashScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'translation.dart'; // Translation file we'll create

import 'firebase_options.dart';

Future<void> main() async {
  if (kDebugMode) {
    debugPrint('🚀 APP STARTING: main() called');
  }
  WidgetsFlutterBinding.ensureInitialized();
  if (kDebugMode) {
    debugPrint('✅ WidgetsFlutterBinding initialized');
  }

  // Initialize Firebase with generated options
  try {
    if (kDebugMode) {
      debugPrint('🔥 Attempting Firebase.initializeApp...');
    }
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 5));
    if (kDebugMode) {
      debugPrint('✅ Firebase initialized successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('❌ Firebase initialization failed or timed out: $e');
    }
  }

  // Load translations
  try {
    if (kDebugMode) {
      debugPrint('🌍 Initializing AppTranslation...');
    }
    await AppTranslation.init();
    if (kDebugMode) {
      debugPrint('✅ AppTranslation initialized');
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('❌ AppTranslation initialization failed: $e');
    }
  }

  if (kDebugMode) {
    debugPrint('🚀 Calling runApp(MyApp)...');
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 🔹 Firebase messaging setup (only if Firebase was initialized)
    try {
      FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
        if (message != null && kDebugMode) {
          debugPrint('App opened with notification: ${message.data}');
        }
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          debugPrint('Foreground message: ${message.notification?.title}');
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (kDebugMode) {
          debugPrint('Notification click: ${message.data}');
        }
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Firebase messaging not available: $e');
      }
    }

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      translations: AppTranslation(),
      locale: const Locale('en', 'US'), // default language
      fallbackLocale: const Locale('en', 'US'),
      home: SplashScreen(),
    );
  }
}
