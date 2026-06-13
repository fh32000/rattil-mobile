import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import '../../../core/services/analytics_service.dart';
import '../../../data/models/audio_track.dart';
import '../../../data/models/memorization_settings.dart';
import '../../../data/repositories/memorization_settings_repository.dart';
import '../../../data/repositories/playback_repository.dart';
import '../../../data/sources/ayah_track_source.dart';
import 'audio_loader.dart';

/// Structured debug logger for audio playback diagnostics.
/// All hifz/memorization logs use the [Hifz] prefix;
/// general track logs use the [Track] prefix.
// ignore: avoid_classes_with_only_static_members
class _AudioLog {
  static void hifz(String msg) {
    // ignore: avoid_print
    print('[Hifz] $msg');
  }

  static void track(String msg) {
    // ignore: avoid_print
    print('[Track] $msg');
  }
}

/// Audio handler for background playback and media controls
/// Supports both legacy track-level and Hifz (ayah-level memorization) modes
class QuranAudioHandler extends BaseAudioHandler
    with SeekHandler, QueueHandler {
  final AudioPlayer _player = AudioPlayer();
  final PlaybackRepository _playbackRepo = PlaybackRepository();
  final MemorizationSettingsRepository _memSettingsRepo =
      MemorizationSettingsRepository();

  final BehaviorSubject<List<AudioTrack>> _trackList = BehaviorSubject.seeded(
    [],
  );
  final BehaviorSubject<int> _currentIndex = BehaviorSubject.seeded(0);
  final BehaviorSubject<LoopMode> _loopMode = BehaviorSubject.seeded(
    LoopMode.off,
  );
  DateTime _lastSkipTime = DateTime(2000);
  bool _isAutoAdvancing = false;
  int _loadGeneration = 0;

  // ─── Hifz / Memorization Mode ───
  bool _hifzMode = false;
  MemorizationSettings _memSettings = const MemorizationSettings();
  MemorizationPlaybackState _memState = const MemorizationPlaybackState();
  List<AudioTrack> _ayahTracks = [];
  Timer? _pauseTimer;
  Timer? _pauseCountdownTimer;

  // Saved legacy state for restoring when Hifz mode is disabled
  List<AudioTrack>? _savedTrackList;
  int _savedTrackIndex = 0;

  final BehaviorSubject<MemorizationSettings> _memSettingsSubject =
      BehaviorSubject.seeded(const MemorizationSettings());
  final BehaviorSubject<MemorizationPlaybackState> _memStateSubject =
      BehaviorSubject.seeded(const MemorizationPlaybackState());
  final BehaviorSubject<String?> _currentPlaylistName =
      BehaviorSubject<String?>.seeded(null);

  // ─── Public Streams ───

  AudioPlayer get player => _player;
  Stream<List<AudioTrack>> get trackListStream => _trackList.stream;
  Stream<int> get currentIndexStream => _currentIndex.stream;
  Stream<LoopMode> get loopModeStream => _loopMode.stream;
  Stream<MemorizationSettings> get memSettingsStream =>
      _memSettingsSubject.stream;
  Stream<MemorizationPlaybackState> get memStateStream =>
      _memStateSubject.stream;
  Stream<String?> get currentPlaylistNameStream => _currentPlaylistName.stream;

  // ─── Public Getters ───

  List<AudioTrack> get currentTrackList => _trackList.value;
  int get currentIndex => _currentIndex.value;

  bool get isHifzMode => _hifzMode;
  MemorizationSettings get memSettings => _memSettings;
  MemorizationPlaybackState get memState => _memState;

  AudioTrack? get currentTrack {
    if (_hifzMode) {
      final idx = _memState.currentAyah - 1;
      if (idx >= 0 && idx < _ayahTracks.length) {
        return _ayahTracks[idx];
      }
      return null;
    }
    final tracks = _trackList.value;
    final idx = _currentIndex.value;
    if (tracks.isEmpty || idx < 0 || idx >= tracks.length) return null;
    return tracks[idx];
  }

  LoopMode get currentLoopMode => _loopMode.value;

  QuranAudioHandler() {
    AyahTrackSource.init();
    _memSettings = _memSettingsRepo.load();
    _memSettingsSubject.add(_memSettings);

    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);

    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _onTrackCompleted();
      }
    }).onError((e) {
      // ignore: avoid_print
      print('processingStateStream error: $e');
    });

    _player.positionStream.throttleTime(const Duration(seconds: 3)).listen((
      position,
    ) {
      _saveCurrentPosition();
    });

    _player.durationStream.listen((duration) {
      if (duration != null && duration > Duration.zero) {
        // ignore: avoid_print
        print('Audio duration resolved: ${duration.inSeconds}s');
      }
    });
  }

  // ─── Legacy Track Loading ───

  /// Load a list of tracks and start playing from the given index
  Future<void> loadTracks(
    List<AudioTrack> tracks, {
    int startIndex = 0,
    String? playlistName,
  }) async {
    if (tracks.isEmpty) return;
    _disableHifzMode();
    _currentPlaylistName.add(playlistName);

    _trackList.add(tracks);
    _currentIndex.add(startIndex);
    queue.add(tracks.map(_trackToMediaItem).toList());

    await _loadCurrentTrack();
  }

  /// Play a single audio asset (e.g. letter pronunciation) through the main player
  Future<void> playSingleAsset({
    required String assetPath,
    required String title,
    String artist = '',
  }) async {
    _disableHifzMode();

    final track = AudioTrack(
      id: 'single_$assetPath',
      surahNumber: 0,
      surahNameArabic: title,
      surahNameEnglish: '',
      reciterName: artist,
      assetPath: assetPath,
      pageNumber: 0,
    );

    _trackList.add([track]);
    _currentIndex.add(0);
    mediaItem.add(MediaItem(id: track.id, title: title, artist: artist));
    queue.add([mediaItem.value!]);

    try {
      await _player.setAudioSource(AudioLoader.createSource(assetPath));
      await _player.play();
    } catch (e) {
      // ignore: avoid_print
      print('Error playing single asset: $assetPath - $e');
    }
  }

  /// Load all letter tracks as a playlist and start from the given index
  Future<void> loadLetterTracks({
    required List<AudioTrack> letterTracks,
    required int startIndex,
    String? playlistName,
  }) async {
    if (letterTracks.isEmpty) return;
    _disableHifzMode();
    _currentPlaylistName.add(playlistName);

    _trackList.add(letterTracks);
    _currentIndex.add(startIndex);
    queue.add(letterTracks.map(_trackToMediaItem).toList());

    final track = letterTracks[startIndex];
    mediaItem.add(_trackToMediaItem(track));

    try {
      await _player.setAudioSource(AudioLoader.createSource(track.assetPath));
      await _player.play();
    } catch (e) {
      // ignore: avoid_print
      print('Error loading letter track: ${track.assetPath} - $e');
    }
  }

  // ─── Hifz Mode ───

  bool get canEnableHifzMode {
    final track = currentTrack;
    if (track == null) return false;
    return AyahTrackSource.hasAyahAudio(track.surahNumber);
  }

  Future<void> enableHifzMode() async {
    if (_hifzMode) return;
    final track = currentTrack;
    if (track == null || !AyahTrackSource.hasAyahAudio(track.surahNumber)) {
      return;
    }

    // Save legacy state
    _savedTrackList = List.from(_trackList.value);
    _savedTrackIndex = _currentIndex.value;

    _hifzMode = true;
    _ayahTracks = AyahTrackSource.getAyahTracks(track.surahNumber);
    if (_ayahTracks.isEmpty) {
      _hifzMode = false;
      return;
    }

    // Replace track list with ayah tracks for UI consumption
    _trackList.add(_ayahTracks);
    _currentIndex.add(0);

    _memState = MemorizationPlaybackState(
      currentAyah: 1,
      currentRepetition: 0,
      currentAyahDuration: Duration.zero,
      totalAyahs: _ayahTracks.length,
      isHifzActive: true,
      isPauseModeActive: _memSettings.pauseForRecitation,
    );
    _memStateSubject.add(_memState);

    final analytics = AnalyticsService.instance;
    analytics.trackHifzStarted(
      track.surahNumber,
      _memSettings.ayahRepeatCount,
      _memSettings.pauseForRecitation,
    );
    analytics.setHifzEnabled(true);
    analytics.setCurrentSurah(track.surahNumber);
    analytics.setRepeatCount(_memSettings.ayahRepeatCount);
    analytics.setPauseMode(_memSettings.pauseForRecitation);

    await _playAyah(1);
  }

  void disableHifzMode() {
    if (!_hifzMode) return;

    _pauseTimer?.cancel();
    _pauseTimer = null;
    _stopPauseCountdown();
    _hifzMode = false;
    _ayahTracks = [];
    _memState = const MemorizationPlaybackState();
    _memStateSubject.add(_memState);

    // Restore legacy state
    final saved = _savedTrackList;
    if (saved != null && saved.isNotEmpty) {
      _trackList.add(saved);
      _currentIndex.add(_savedTrackIndex);
      _savedTrackList = null;
      _loadCurrentTrack();
    }
  }

  void _disableHifzMode() {
    _pauseTimer?.cancel();
    _pauseTimer = null;
    _stopPauseCountdown();
    _hifzMode = false;
    _ayahTracks = [];
    _memState = const MemorizationPlaybackState();
    _memStateSubject.add(_memState);
    _savedTrackList = null;
  }

  /// Load and play the current track (from _trackList and _currentIndex)
  Future<void> _loadCurrentTrack() async {
    final track = currentTrack;
    if (track == null) return;

    final gen = ++_loadGeneration;

    mediaItem.add(_trackToMediaItem(track));

    _AudioLog.track('Loading track: ${track.id} - ${track.assetPath}');

    try {
      await _player.setAudioSource(AudioLoader.createSource(track.assetPath));
      if (gen != _loadGeneration) return;

      // Apply saved playback speed globally (not just in hifz mode)
      if (_memSettings.playbackSpeed != 1.0) {
        await _player.setSpeed(_memSettings.playbackSpeed);
      }
      if (gen != _loadGeneration) return;

      if (!_isAutoAdvancing) {
        final savedPosition = _playbackRepo.getPosition(track.id);
        if (savedPosition != null && savedPosition > 0) {
          _AudioLog.track(
            'Stored position for ${track.id}: ${savedPosition}ms',
          );

          final duration = await _resolveDuration(timeout: const Duration(seconds: 3));
          if (gen != _loadGeneration) return;
          final isValid = duration > Duration.zero &&
              savedPosition < duration.inMilliseconds;

          _AudioLog.track(
            'Position validation: duration=${duration.inMilliseconds}ms, '
            'saved=${savedPosition}ms, valid=$isValid',
          );

          if (isValid) {
            await _player.seek(Duration(milliseconds: savedPosition));
            if (gen != _loadGeneration) return;
            _AudioLog.track('Seeked to saved position: ${savedPosition}ms');
          } else {
            _AudioLog.track(
              'Invalid position ${savedPosition}ms for duration '
              '${duration.inMilliseconds}ms — resetting to 0',
            );
            _playbackRepo.savePosition(track.id, 0);
          }
        }
      } else {
        _AudioLog.track('Auto-advancing — starting from beginning');
      }

      if (gen != _loadGeneration) return;
      await _player.play();
      if (gen != _loadGeneration) return;
      _isAutoAdvancing = false;
      _AudioLog.track('Playback started for ${track.id}');
      AnalyticsService.instance.trackPlaybackStarted(track.surahNumber, 0);
    } catch (e) {
      if (gen != _loadGeneration) return;
      _AudioLog.track('Error loading track: ${track.assetPath} - $e');
      _isAutoAdvancing = false;
      AnalyticsService.instance.recordError(
        e,
        StackTrace.current,
        reason: 'track_playback_failed',
      );
    }
  }

  void updateMemorizationSettings(MemorizationSettings settings) {
    final speedChanged = settings.playbackSpeed != _memSettings.playbackSpeed;
    final volumeChanged = settings.volume != _memSettings.volume;

    _memSettings = settings;
    _memSettingsSubject.add(settings);
    _memSettingsRepo.save(settings);

    if (speedChanged) {
      _player.setSpeed(settings.playbackSpeed);
    }
    if (volumeChanged) {
      _player.setVolume(settings.volume);
    }

    _memState = _memState.copyWith(
      isPauseModeActive: settings.pauseForRecitation,
    );
    _memStateSubject.add(_memState);
  }

  void setVolume(double volume) {
    updateMemorizationSettings(_memSettings.copyWith(volume: volume));
  }

  void setPlaybackSpeed(double speed) {
    updateMemorizationSettings(_memSettings.copyWith(playbackSpeed: speed));
  }

  // ─── Ayah Playback ───

  Future<void> _playAyah(int ayahNumber) async {
    if (!_hifzMode || _ayahTracks.isEmpty) return;

    final ayahIndex = ayahNumber - 1;
    if (ayahIndex < 0 || ayahIndex >= _ayahTracks.length) {
      _handleSurahComplete();
      return;
    }

    final gen = ++_loadGeneration;
    final track = _ayahTracks[ayahIndex];

    _memState = _memState.copyWith(
      currentAyah: ayahNumber,
      totalAyahs: _ayahTracks.length,
      phase: HifzPhase.listening,
    );
    _memStateSubject.add(_memState);

    _currentIndex.add(ayahIndex);
    mediaItem.add(_trackToMediaItem(track));

    final analytics = AnalyticsService.instance;
    analytics.setCurrentAyah(ayahNumber);

    _AudioLog.hifz('Loading ayah $ayahNumber: ${track.assetPath}');

    try {
      await _player.setAudioSource(AudioLoader.createSource(track.assetPath));
      if (gen != _loadGeneration) return;
      _AudioLog.hifz('Source set for ayah $ayahNumber');

      await _player.setSpeed(_memSettings.playbackSpeed);
      if (gen != _loadGeneration) return;
      await _player.setVolume(_memSettings.volume);
      if (gen != _loadGeneration) return;

      await _player.play().timeout(const Duration(seconds: 8));
      if (gen != _loadGeneration) return;
      _AudioLog.hifz('Playback started for ayah $ayahNumber');

      analytics.trackPlaybackStarted(track.surahNumber, ayahNumber);
    } on TimeoutException {
      if (gen != _loadGeneration) return;
      _AudioLog.hifz('Timeout playing ayah $ayahNumber — no fallback, skipping');
    } catch (e) {
      if (gen != _loadGeneration) return;
      _AudioLog.hifz('Error playing ayah: ${track.assetPath} - $e');
      analytics.recordError(
        e,
        StackTrace.current,
        reason: 'ayah_playback_failed',
      );
    }
  }

  Future<Duration> _resolveDuration({Duration timeout = const Duration(seconds: 5)}) async {
    final d = _player.duration;
    if (d != null && d > Duration.zero) return d;
    try {
      final resolved = await _player.durationStream
          .firstWhere((d) => d != null && d > Duration.zero)
          .timeout(timeout);
      return resolved ?? Duration.zero;
    } on TimeoutException {
      return Duration.zero;
    }
  }

  Future<void> _handleAyahCompleted() async {
    if (!_hifzMode) return;

    final ayahDuration = await _resolveDuration();
    _memState = _memState.copyWith(currentAyahDuration: ayahDuration);
    _memStateSubject.add(_memState);

    final nextRep = _memState.currentRepetition + 1;

    // Basmala (currentAyah == 1) repeats only once for all surahs except Al-Fatihah
    final surahNumber = _ayahTracks.first.surahNumber;
    final isBasmala = surahNumber != 1 && _memState.currentAyah == 1;
    final repCount = isBasmala ? 1 : _memSettings.ayahRepeatCount;

    // Track ayah repetition
    final analytics = AnalyticsService.instance;
    analytics.trackAyahRepeated(
      surahNumber,
      _memState.currentAyah,
      nextRep,
    );

    if (nextRep < repCount) {
      _memState = _memState.copyWith(currentRepetition: nextRep);
      _memStateSubject.add(_memState);
      _scheduleNextPlayback(() => _playAyah(_memState.currentAyah));
      return;
    }

    final nextAyah = _memState.currentAyah + 1;
    if (nextAyah <= _ayahTracks.length) {
      // Don't advance currentAyah yet — wait until pause finishes
      _scheduleNextPlayback(() async {
        _memState = _memState.copyWith(
          currentAyah: nextAyah,
          currentRepetition: 0,
        );
        _memStateSubject.add(_memState);
        await _playAyah(nextAyah);
      });
      return;
    }

    _handleSurahComplete();
  }

  void _handleSurahComplete() {
    final surahNumber = _ayahTracks.isNotEmpty
        ? _ayahTracks.first.surahNumber
        : 0;
    final analytics = AnalyticsService.instance;
    analytics.trackHifzCompleted(surahNumber);

    if (_memSettings.repeatSurah) {
      _memState = _memState.copyWith(currentAyah: 1, currentRepetition: 0);
      _memStateSubject.add(_memState);
      _playAyah(1);
      return;
    }

    final saved = _savedTrackList;
    final savedIndex = _savedTrackIndex;
    _disableHifzMode();
    _player.stop();

    if (saved != null) {
      final nextIndex = savedIndex + 1;
      if (nextIndex < saved.length) {
        _trackList.add(saved);
        _currentIndex.add(nextIndex);
      }
    }
  }

  void _scheduleNextPlayback(void Function() playAction) {
    if (_memSettings.pauseForRecitation) {
      _pauseTimer?.cancel();
      _stopPauseCountdown();

      final raw = _memState.currentAyahDuration;
      final scaled = raw > Duration.zero
          ? Duration(
              milliseconds: (raw.inMilliseconds /
                      _memSettings.playbackSpeed *
                      _memSettings.recitationMultiplier)
                  .round(),
            )
          : const Duration(seconds: 1);

      _player.pause();

      _memState = _memState.copyWith(
        phase: HifzPhase.reciting,
        pauseRemaining: scaled,
        pauseTotalDuration: scaled,
      );
      _memStateSubject.add(_memState);

      _pauseCountdownTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
        final remaining = _memState.pauseRemaining! - const Duration(milliseconds: 200);
        _memState = _memState.copyWith(
          pauseRemaining: remaining > Duration.zero ? remaining : Duration.zero,
        );
        _memStateSubject.add(_memState);
      });

      _pauseTimer = Timer(scaled, () {
        _stopPauseCountdown();
        _pauseTimer = null;
        _memState = _memState.copyWith(
          phase: HifzPhase.listening,
          pauseRemaining: Duration.zero,
        );
        _memStateSubject.add(_memState);
        playAction();
      });
    } else {
      playAction();
    }
  }

  void _stopPauseCountdown() {
    _pauseCountdownTimer?.cancel();
    _pauseCountdownTimer = null;
  }

  // ─── Track Completion ───

  Future<void> _onTrackCompleted() async {
    if (_hifzMode) {
      await _handleAyahCompleted();
      return;
    }

    // Track playback completion for non-Hifz mode
    final track = currentTrack;
    if (track != null) {
      AnalyticsService.instance.trackPlaybackCompleted(track.surahNumber);
    }

    switch (_loopMode.value) {
      case LoopMode.one:
        _player.seek(Duration.zero);
        _player.play();
        break;
      case LoopMode.all:
        _isAutoAdvancing = true;
        skipToNext();
        break;
      case LoopMode.off:
        if (_currentIndex.value < _trackList.value.length - 1) {
          _isAutoAdvancing = true;
          skipToNext();
        }
        break;
    }
  }

  void _saveCurrentPosition({bool completed = false}) {
    if (_hifzMode || _isAutoAdvancing) return;

    final track = currentTrack;
    if (track == null) return;

    if (completed) {
      _playbackRepo.savePosition(track.id, 0);
    } else {
      _playbackRepo.savePosition(track.id, _player.position.inMilliseconds);
    }
  }

  /// Cycle loop mode: off → one → all → off
  void cycleLoopMode() {
    switch (_loopMode.value) {
      case LoopMode.off:
        _loopMode.add(LoopMode.one);
        break;
      case LoopMode.one:
        _loopMode.add(LoopMode.all);
        break;
      case LoopMode.all:
        _loopMode.add(LoopMode.off);
        break;
    }
  }

  // ─── BaseAudioHandler overrides ───

  @override
  Future<void> play() async {
    AnalyticsService.instance.trackPlaybackResumed();
    await _player.play();
  }

  @override
  Future<void> pause() async {
    if (!_hifzMode) {
      _pauseTimer?.cancel();
    }
    _saveCurrentPosition();
    await _player.pause();
    AnalyticsService.instance.trackPlaybackPaused();
  }

  @override
  Future<void> stop() async {
    _AudioLog.track('stop() called — stopping playback');
    _pauseTimer?.cancel();
    _stopPauseCountdown();
    _hifzMode = false;
    _ayahTracks = [];
    _memState = const MemorizationPlaybackState();
    _memStateSubject.add(_memState);
    _savedTrackList = null;
    _trackList.add([]);
    _currentIndex.add(0);
    await _player.stop();
    mediaItem.add(null);
    queue.add([]);
    _AudioLog.track('stop() complete — player stopped, media cleared');
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    if (_hifzMode) {
      _pauseTimer?.cancel();
      _stopPauseCountdown();
      _memState = _memState.copyWith(
        phase: HifzPhase.listening,
        pauseRemaining: null,
        pauseTotalDuration: null,
      );
      _memStateSubject.add(_memState);
      final nextAyah = _memState.currentAyah + 1;
      if (nextAyah <= _ayahTracks.length) {
        _memState = _memState.copyWith(
          currentAyah: nextAyah,
          currentRepetition: 0,
        );
        _memStateSubject.add(_memState);
        await _playAyah(nextAyah);
      } else {
        _handleSurahComplete();
      }
      return;
    }

    // Debounce: ignore rapid presses within 500ms
    final now = DateTime.now();
    if (now.difference(_lastSkipTime).inMilliseconds < 500) return;
    _lastSkipTime = now;

    _saveCurrentPosition();
    final tracks = _trackList.value;
    final nextIndex = _currentIndex.value + 1;

    if (nextIndex < tracks.length) {
      _currentIndex.add(nextIndex);
      await _loadCurrentTrack();
    } else if (_loopMode.value == LoopMode.all) {
      _currentIndex.add(0);
      await _loadCurrentTrack();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_hifzMode) {
      _pauseTimer?.cancel();
      _stopPauseCountdown();
      _memState = _memState.copyWith(
        phase: HifzPhase.listening,
        pauseRemaining: null,
        pauseTotalDuration: null,
      );
      _memStateSubject.add(_memState);
      final prevAyah = _memState.currentAyah - 1;
      if (prevAyah >= 1) {
        _memState = _memState.copyWith(
          currentAyah: prevAyah,
          currentRepetition: 0,
        );
        _memStateSubject.add(_memState);
        await _playAyah(prevAyah);
      }
      return;
    }

    // Debounce: ignore rapid presses within 500ms
    final now = DateTime.now();
    if (now.difference(_lastSkipTime).inMilliseconds < 500) return;
    _lastSkipTime = now;

    // If more than 3 seconds in, restart current track
    if (_player.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
      return;
    }

    _saveCurrentPosition();
    final prevIndex = _currentIndex.value - 1;

    if (prevIndex >= 0) {
      _currentIndex.add(prevIndex);
      await _loadCurrentTrack();
    } else if (_loopMode.value == LoopMode.all) {
      _currentIndex.add(_trackList.value.length - 1);
      await _loadCurrentTrack();
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (_hifzMode) return;
    _saveCurrentPosition();
    if (index >= 0 && index < _trackList.value.length) {
      _currentIndex.add(index);
      await _loadCurrentTrack();
    }
  }

  /// Fast forward 10 seconds
  Future<void> fastForward10() async {
    final newPosition = _player.position + const Duration(seconds: 10);
    final duration = _player.duration ?? Duration.zero;
    await _player.seek(newPosition > duration ? duration : newPosition);
  }

  /// Rewind 10 seconds
  Future<void> rewind10() async {
    final newPosition = _player.position - const Duration(seconds: 10);
    await _player.seek(
      newPosition < Duration.zero ? Duration.zero : newPosition,
    );
  }

  MediaItem _trackToMediaItem(AudioTrack track) {
    return MediaItem(
      id: track.id,
      title: track.displayName,
      artist: track.reciterName,
      album: 'جزء عمّ',
      extras: {
        'surahNumber': track.surahNumber,
        'pageNumber': track.pageNumber,
      },
    );
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
        const MediaControl(
          androidIcon: 'drawable/audio_service_close',
          label: 'إغلاق',
          action: MediaAction.stop,
        ),
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: _currentIndex.value,
    );
  }

  Future<void> dispose() async {
    _pauseTimer?.cancel();
    _stopPauseCountdown();
    _saveCurrentPosition();
    await _player.dispose();
    await _trackList.close();
    await _currentIndex.close();
    await _loopMode.close();
    await _memSettingsSubject.close();
    await _memStateSubject.close();
  }
}

/// Loop mode enum matching just_audio
enum LoopMode { off, one, all }
