import 'package:bseb/view_controllers/SplashScreen.dart';
import 'package:bseb/utilities/SharedPreferencesHelper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'translation.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences early for faster access throughout the app
  await SharedPreferencesHelper.init();

  // Initialize Firebase with timeout to prevent blocking
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 5));
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Firebase initialization failed: $e');
    }
  }

  // Load translations
  try {
    await AppTranslation.init();
  } catch (e) {
    if (kDebugMode) {
      debugPrint('AppTranslation initialization failed: $e');
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Move Firebase messaging setup to initState (runs only once)
    _setupFirebaseMessaging();
  }

  void _setupFirebaseMessaging() {
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
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      translations: AppTranslation(),
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
      home: const SplashScreen(),
      // Performance optimizations
      builder: (context, child) {
        return MediaQuery(
          // Prevent text scaling issues
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
          child: child!,
        );
      },
    );
  }
}
