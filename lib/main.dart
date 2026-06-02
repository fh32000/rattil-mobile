import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
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

  // Initialize Hive for local storage
  await HiveService.init();

  // Initialize audio service (handles web gracefully)
  await initAudioService();

  runApp(
    const ProviderScope(
      child: RattilApp(),
    ),
  );
}
