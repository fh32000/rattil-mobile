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

  // Initialize Firebase
  await Firebase.initializeApp();

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
    appVersion: '1.0.13+1',
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
