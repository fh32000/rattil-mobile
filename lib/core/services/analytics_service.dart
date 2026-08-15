import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService instance = AnalyticsService._();

  FirebaseAnalytics? _analytics;
  FirebaseCrashlytics? get crashlytics => _crashlytics;
  FirebaseCrashlytics? _crashlytics;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      _analytics = FirebaseAnalytics.instance;
      _crashlytics = FirebaseCrashlytics.instance;
      await _crashlytics!.setCrashlyticsCollectionEnabled(true);
      _initialized = true;
    } catch (_) {}
  }

  void _guard(void Function() fn) {
    if (!_initialized) return;
    try {
      fn();
    } catch (_) {}
  }

  Future<void> _guardAsync(Future<void> Function() fn) async {
    if (!_initialized) return;
    try {
      await fn();
    } catch (_) {}
  }

  // ─── User Properties ───

  Future<void> setUserProperties({
    required String appVersion,
    required String platform,
    required String language,
    String? themeMode,
  }) async {
    await _guardAsync(() async {
      await _analytics!.setUserProperty(name: 'app_version', value: appVersion);
      await _analytics!.setUserProperty(name: 'platform', value: platform);
      await _analytics!.setUserProperty(name: 'language', value: language);
      if (themeMode != null) {
        await _analytics!.setUserProperty(name: 'theme_mode', value: themeMode);
      }
    });
  }

  // ─── App Lifecycle ───

  void trackAppOpen() {
    _guard(() {
      _analytics!.logAppOpen();
    });
  }

  void trackSessionStart() {
    _guard(() {
      _analytics!.logEvent(name: 'session_start');
    });
  }

  // ─── Screen Views ───

  void trackScreenView(String screenName) {
    _guard(() {
      _analytics!.logScreenView(
        screenName: screenName,
        screenClass: screenName,
      );
    });
  }

  // ─── Quran Events ───

  void trackSurahOpened(int surahId, String surahName) {
    _guard(() {
      _analytics!.logEvent(
        name: 'surah_opened',
        parameters: {
          'surah_id': surahId,
          'surah_name': surahName,
        },
      );
    });
  }

  void trackPlaybackStarted(int surahId, int ayah) {
    _guard(() {
      _analytics!.logEvent(
        name: 'playback_started',
        parameters: {
          'surah_id': surahId,
          'ayah': ayah,
        },
      );
    });
  }

  void trackPlaybackPaused() {
    _guard(() {
      _analytics!.logEvent(name: 'playback_paused');
    });
  }

  void trackPlaybackResumed() {
    _guard(() {
      _analytics!.logEvent(name: 'playback_resumed');
    });
  }

  void trackPlaybackCompleted(int surahId) {
    _guard(() {
      _analytics!.logEvent(
        name: 'playback_completed',
        parameters: {'surah_id': surahId},
      );
    });
  }

  // ─── Hifz Events ───

  void trackHifzStarted(int surahId, int repeatCount, bool pauseMode) {
    _guard(() {
      _analytics!.logEvent(
        name: 'hifz_started',
        parameters: {
          'surah_id': surahId,
          'repeat_count': repeatCount,
          'pause_mode': pauseMode ? 'true' : 'false',
        },
      );
    });
  }

  void trackHifzCompleted(int surahId) {
    _guard(() {
      _analytics!.logEvent(
        name: 'hifz_completed',
        parameters: {'surah_id': surahId},
      );
    });
  }

  void trackHifzRepeatChanged(int oldValue, int newValue) {
    _guard(() {
      _analytics!.logEvent(
        name: 'hifz_repeat_changed',
        parameters: {
          'old_value': oldValue,
          'new_value': newValue,
        },
      );
    });
  }

  void trackHifzSpeedChanged(double speed) {
    _guard(() {
      _analytics!.logEvent(
        name: 'hifz_speed_changed',
        parameters: {'speed': speed},
      );
    });
  }

  void trackHifzRecitationMultiplierChanged(double multiplier) {
    _guard(() {
      _analytics!.logEvent(
        name: 'hifz_recitation_multiplier_changed',
        parameters: {'multiplier': multiplier},
      );
    });
  }

  void trackHifzHideVerses(bool enabled) {
    _guard(() {
      _analytics!.logEvent(
        name: 'hifz_hide_verses_enabled',
        parameters: {'enabled': enabled ? 'true' : 'false'},
      );
    });
  }

  void trackHifzPauseMode(bool enabled) {
    _guard(() {
      _analytics!.logEvent(
        name: 'hifz_pause_mode_changed',
        parameters: {'enabled': enabled ? 'true' : 'false'},
      );
    });
  }

  void trackHifzSurahRepeat(bool enabled) {
    _guard(() {
      _analytics!.logEvent(
        name: 'hifz_surah_repeat_changed',
        parameters: {'enabled': enabled ? 'true' : 'false'},
      );
    });
  }

  void trackAyahRepeated(int surahId, int ayah, int repeatCount) {
    _guard(() {
      _analytics!.logEvent(
        name: 'ayah_repeated',
        parameters: {
          'surah_id': surahId,
          'ayah': ayah,
          'repeat_count': repeatCount,
        },
      );
    });
  }

  // ─── Favorites ───

  void trackFavoriteAdded(int surahId) {
    _guard(() {
      _analytics!.logEvent(
        name: 'favorite_added',
        parameters: {'surah_id': surahId},
      );
    });
  }

  void trackFavoriteRemoved(int surahId) {
    _guard(() {
      _analytics!.logEvent(
        name: 'favorite_removed',
        parameters: {'surah_id': surahId},
      );
    });
  }

  // ─── Settings ───

  void trackSettingsChanged(String setting) {
    _guard(() {
      _analytics!.logEvent(
        name: 'settings_changed',
        parameters: {'setting': setting},
      );
    });
  }

  // ─── Search ───

  void trackSearchPerformed(int queryLength) {
    _guard(() {
      _analytics!.logEvent(
        name: 'search_performed',
        parameters: {'query_length': queryLength},
      );
    });
  }

  // ─── Non-fatal Error Recording ───

  Future<void> recordError(
    Object exception,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {
    await _guardAsync(() async {
      await _crashlytics!.recordError(exception, stack, reason: reason, fatal: fatal);
    });
  }

  Future<void> recordFlutterError(FlutterErrorDetails details, {bool fatal = false}) async {
    await _guardAsync(() async {
      await _crashlytics!.recordFlutterError(details, fatal: fatal);
    });
  }

  // ─── Crashlytics Custom Keys ───

  Future<void> setCustomKey(String key, Object value) async {
    await _guardAsync(() async {
      await _crashlytics!.setCustomKey(key, value);
    });
  }

  void setCurrentSurah(int surahId) {
    setCustomKey('surah_id', surahId);
  }

  void setCurrentAyah(int ayah) {
    setCustomKey('ayah_number', ayah);
  }

  void setHifzEnabled(bool enabled) {
    setCustomKey('hifz_enabled', enabled);
  }

  void setRepeatCount(int count) {
    setCustomKey('repeat_count', count);
  }

  void setPlaybackSpeed(double speed) {
    setCustomKey('playback_speed', speed);
  }

  void setPauseMode(bool enabled) {
    setCustomKey('pause_mode_enabled', enabled);
  }
}
