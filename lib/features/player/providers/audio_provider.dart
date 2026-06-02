import 'package:flutter/foundation.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';
import '../../../core/services/analytics_service.dart';
import '../../../data/models/audio_track.dart';
import '../../../data/models/memorization_settings.dart';
import '../../../data/repositories/favorites_repository.dart';
import '../../../data/sources/ayah_track_source.dart';
import '../services/audio_handler.dart';

// ─── Global audio handler initialization ───

late QuranAudioHandler _audioHandler;

Future<void> initAudioService() async {
  if (kIsWeb) {
    try {
      _audioHandler = QuranAudioHandler();
    } catch (e) {
      // ignore: avoid_print
      print('Error creating audio handler on web: $e');
      rethrow;
    }
    return;
  }
  _audioHandler = await AudioService.init(
    builder: () => QuranAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.rattil.audio',
      androidNotificationChannelName: 'ورتِّله',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
}

// ─── Core Audio Providers ───

/// Provides the audio handler instance
final audioHandlerProvider = Provider<QuranAudioHandler>((ref) {
  return _audioHandler;
});

/// Current playing track
final currentTrackProvider = StreamProvider<AudioTrack?>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return Rx.combineLatest2(
    handler.trackListStream,
    handler.currentIndexStream,
    (List<AudioTrack> tracks, int index) {
      if (tracks.isEmpty || index < 0 || index >= tracks.length) return null;
      return tracks[index];
    },
  );
});

/// Is currently playing
final isPlayingProvider = StreamProvider<bool>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.playbackState.map((state) => state.playing).distinct();
});

/// Current position
final positionProvider = StreamProvider<Duration>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.player.positionStream;
});

/// Track duration
final durationProvider = StreamProvider<Duration?>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.player.durationStream;
});

/// Buffered position
final bufferedPositionProvider = StreamProvider<Duration>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.player.bufferedPositionStream;
});

/// Loop mode
final loopModeProvider = StreamProvider<LoopMode>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.loopModeStream;
});

/// Current track list
final trackListProvider = StreamProvider<List<AudioTrack>>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.trackListStream;
});

/// Current track index
final currentIndexProvider = StreamProvider<int>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.currentIndexStream;
});

// ─── Hifz / Memorization Providers ───

/// Whether hifz mode is available for the current track
final canEnableHifzModeProvider = Provider<bool>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  final track = ref.watch(currentTrackProvider).valueOrNull;
  if (track == null) return false;
  return AyahTrackSource.hasAyahAudio(track.surahNumber);
});

/// Whether hifz mode is currently active
final isHifzModeActiveProvider = Provider<bool>((ref) {
  final memState = ref.watch(memorizationPlaybackStateProvider).valueOrNull;
  return memState?.isHifzActive ?? false;
});

/// Memorization settings
final memorizationSettingsProvider = StreamProvider<MemorizationSettings>((
  ref,
) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.memSettingsStream;
});

/// Memorization playback state
final memorizationPlaybackStateProvider =
    StreamProvider<MemorizationPlaybackState>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.memStateStream;
});

// ─── Favorites ───

final favoritesRepositoryProvider = Provider((ref) => FavoritesRepository());

/// Favorites notifier
class FavoritesNotifier extends StateNotifier<Set<String>> {
  final FavoritesRepository _repo;

  FavoritesNotifier(this._repo) : super(_repo.getAllFavorites().toSet());

  bool isFavorite(String trackId) => state.contains(trackId);

  void toggle(String trackId) {
    final wasFavorite = state.contains(trackId);
    _repo.toggleFavorite(trackId);
    state = _repo.getAllFavorites().toSet();

    // Extract surah ID from track ID (format: "juz_amma_078" or "078_ayah_001")
    final parts = trackId.split('_');
    final surahId = int.tryParse(parts.lastWhere(
      (p) => int.tryParse(p) != null,
      orElse: () => '0',
    )) ?? 0;

    final analytics = AnalyticsService.instance;
    if (wasFavorite) {
      analytics.trackFavoriteRemoved(surahId);
    } else {
      analytics.trackFavoriteAdded(surahId);
    }
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  final repo = ref.watch(favoritesRepositoryProvider);
  return FavoritesNotifier(repo);
});
