import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'core/services/analytics_service.dart';
import 'data/hive/hive_service.dart';
import 'features/player/providers/audio_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait (mobile only)
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // Initialize Firebase (web requires explicit options)
  await Firebase.initializeApp(
    options: kIsWeb
        ? const FirebaseOptions(
            apiKey: 'AIzaSyA7Wi0tvZN5Emi1xzAJs0qr590GDM33BAo',
            authDomain: 'rattil-99355.firebaseapp.com',
            projectId: 'rattil-99355',
            storageBucket: 'rattil-99355.firebasestorage.app',
            messagingSenderId: '80692180579',
            appId: '1:80692180579:web:36d3602b5132a6376bea56',
            measurementId: 'G-8JPHJCN7EM',
          )
        : null,
  );

  // Initialize Analytics & Crashlytics
  final analytics = AnalyticsService.instance;
  await analytics.init();

  // Flutter errors → Crashlytics
  FlutterError.onError = (details) {
    analytics.recordFlutterError(details, fatal: true);
  };

  // Platform errors → Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    analytics.recordError(error, stack, fatal: true);
    return true;
  };

  // Initialize Hive for local storage
  await HiveService.init();

  // Initialize audio service (handles web gracefully)
  await initAudioService();

  // Track app open
  analytics.trackAppOpen();

  // Set user properties
  analytics.setUserProperties(
    appVersion: '1.0.16+4',
    platform: kIsWeb ? 'web' : defaultTargetPlatform.name,
    language: 'ar',
    themeMode: 'dark',
  );

  runApp(
    const ProviderScope(
      child: RattilApp(),
    ),
  );
}
