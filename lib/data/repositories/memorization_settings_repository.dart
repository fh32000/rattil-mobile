import 'dart:convert';
import '../hive/hive_service.dart';
import '../models/memorization_settings.dart';

class MemorizationSettingsRepository {
  static const String _key = 'hifz_settings';

  MemorizationSettings load() {
    final raw = HiveService.settingsBox.get(_key);
    if (raw is String) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        return MemorizationSettings.fromMap(map);
      } catch (_) {
        // ignore: corrupted data
      }
    }
    return const MemorizationSettings();
  }

  void save(MemorizationSettings settings) {
    HiveService.settingsBox.put(_key, jsonEncode(settings.toMap()));
  }

  void clear() {
    HiveService.settingsBox.delete(_key);
  }
}
