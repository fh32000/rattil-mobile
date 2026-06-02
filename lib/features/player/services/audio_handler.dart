import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import '../../../data/models/audio_track.dart';
import '../../../data/models/memorization_settings.dart';
import '../../../data/repositories/playback_repository.dart';
import '../../../data/sources/ayah_track_source.dart';

/// Audio handler for background playback and media controls
/// Supports both legacy track-level and Hifz (ayah-level memorization) modes
class QuranAudioHandler extends BaseAudioHandler
    with SeekHandler, QueueHandler {
  final AudioPlayer _player = AudioPlayer();
  final PlaybackRepository _playbackRepo = PlaybackRepository();

  final BehaviorSubject<List<AudioTrack>> _trackList = BehaviorSubject.seeded(
    [],
  );
  final BehaviorSubject<int> _currentIndex = BehaviorSubject.seeded(0);
  final BehaviorSubject<LoopMode> _loopMode = BehaviorSubject.seeded(
    LoopMode.off,
  );
  DateTime _lastSkipTime = DateTime(2000);

  // ─── Hifz / Memorization Mode ───
  bool _hifzMode = false;
  MemorizationSettings _memSettings = const MemorizationSettings();
  MemorizationPlaybackState _memState = const MemorizationPlaybackState();
  List<AudioTrack> _ayahTracks = [];
  Timer? _pauseTimer;

  // Saved legacy state for restoring when Hifz mode is disabled
  List<AudioTrack>? _savedTrackList;
  int _savedTrackIndex = 0;

  final BehaviorSubject<MemorizationSettings> _memSettingsSubject =
      BehaviorSubject.seeded(const MemorizationSettings());
  final BehaviorSubject<MemorizationPlaybackState> _memStateSubject =
      BehaviorSubject.seeded(const MemorizationPlaybackState());

  // ─── Public Streams ───

  AudioPlayer get player => _player;
  Stream<List<AudioTrack>> get trackListStream => _trackList.stream;
  Stream<int> get currentIndexStream => _currentIndex.stream;
  Stream<LoopMode> get loopModeStream => _loopMode.stream;
  Stream<MemorizationSettings> get memSettingsStream =>
      _memSettingsSubject.stream;
  Stream<MemorizationPlaybackState> get memStateStream =>
      _memStateSubject.stream;

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
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);

    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _onTrackCompleted();
      }
    });

    _player.positionStream.throttleTime(const Duration(seconds: 3)).listen((
      position,
    ) {
      _saveCurrentPosition();
    });
  }

  // ─── Legacy Track Loading ───

  /// Load a list of tracks and start playing from the given index
  Future<void> loadTracks(List<AudioTrack> tracks, {int startIndex = 0}) async {
    if (tracks.isEmpty) return;
    _disableHifzMode();

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
      await _player.setAsset(assetPath);
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
  }) async {
    if (letterTracks.isEmpty) return;
    _disableHifzMode();

    _trackList.add(letterTracks);
    _currentIndex.add(startIndex);
    queue.add(letterTracks.map(_trackToMediaItem).toList());

    final track = letterTracks[startIndex];
    mediaItem.add(_trackToMediaItem(track));

    try {
      await _player.setAsset(track.assetPath);
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

    await _playAyah(1);
  }

  void disableHifzMode() {
    if (!_hifzMode) return;

    _pauseTimer?.cancel();
    _pauseTimer = null;
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

    mediaItem.add(_trackToMediaItem(track));

    try {
      await _player.setAsset(track.assetPath);
      final savedPosition = _playbackRepo.getPosition(track.id);
      if (savedPosition != null && savedPosition > 0) {
        await _player.seek(Duration(milliseconds: savedPosition));
      }
      await _player.play();
    } catch (e) {
      // Log error but don't crash – asset might be missing
      // ignore: avoid_print
      print('Error loading track: ${track.assetPath} - $e');
    }
  }

  void updateMemorizationSettings(MemorizationSettings settings) {
    _memSettings = settings;
    _memSettingsSubject.add(settings);

    _memState = _memState.copyWith(
      isPauseModeActive: settings.pauseForRecitation,
    );
    _memStateSubject.add(_memState);
  }

  // ─── Ayah Playback ───

  Future<void> _playAyah(int ayahNumber) async {
    if (!_hifzMode || _ayahTracks.isEmpty) return;

    final ayahIndex = ayahNumber - 1;
    if (ayahIndex < 0 || ayahIndex >= _ayahTracks.length) {
      _handleSurahComplete();
      return;
    }

    final track = _ayahTracks[ayahIndex];

    _memState = _memState.copyWith(
      currentAyah: ayahNumber,
      currentRepetition: 0,
      totalAyahs: _ayahTracks.length,
    );
    _memStateSubject.add(_memState);

    _currentIndex.add(ayahIndex);

    // Update media notification
    mediaItem.add(_trackToMediaItem(track));

    try {
      await _player.stop();
      await _player.setAsset(track.assetPath);
      await _player.play();
    } catch (e) {
      // ignore: avoid_print
      print('Error playing ayah: ${track.assetPath} - $e');
    }
  }

  void _handleAyahCompleted() {
    if (!_hifzMode) return;

    final ayahDuration = _player.duration ?? Duration.zero;
    _memState = _memState.copyWith(currentAyahDuration: ayahDuration);
    _memStateSubject.add(_memState);

    final nextRep = _memState.currentRepetition + 1;

    if (nextRep < _memSettings.ayahRepeatCount) {
      // More repetitions of current ayah
      _memState = _memState.copyWith(currentRepetition: nextRep);
      _memStateSubject.add(_memState);

      if (_memSettings.pauseForRecitation) {
        _startPauseTimer(() => _playAyah(_memState.currentAyah));
      } else {
        _playAyah(_memState.currentAyah);
      }
    } else {
      // Done with this ayah
      if (_memSettings.pauseForRecitation) {
        _startPauseTimer(() => _advanceToNextAyah());
      } else {
        _advanceToNextAyah();
      }
    }
  }

  void _advanceToNextAyah() {
    final nextAyah = _memState.currentAyah + 1;
    if (nextAyah <= _ayahTracks.length) {
      _playAyah(nextAyah);
    } else {
      _handleSurahComplete();
    }
  }

  void _handleSurahComplete() {
    if (_memSettings.repeatSurah) {
      _playAyah(1);
    } else {
      _disableHifzMode();
      _player.stop();

      // Restore legacy state
      final saved = _savedTrackList;
      if (saved != null) {
        _trackList.add(saved);
        _currentIndex.add(_savedTrackIndex);
        _savedTrackList = null;
      }
    }
  }

  void _startPauseTimer(void Function() onComplete) {
    _pauseTimer?.cancel();
    final pauseDuration = _memState.currentAyahDuration;
    _player.pause();

    _pauseTimer = Timer(pauseDuration, () {
      _pauseTimer = null;
      onComplete();
    });
  }

  // ─── Track Completion ───

  void _onTrackCompleted() {
    _saveCurrentPosition(completed: true);

    if (_hifzMode) {
      _handleAyahCompleted();
      return;
    }

    switch (_loopMode.value) {
      case LoopMode.one:
        _player.seek(Duration.zero);
        _player.play();
        break;
      case LoopMode.all:
        skipToNext();
        break;
      case LoopMode.off:
        if (_currentIndex.value < _trackList.value.length - 1) {
          skipToNext();
        }
        break;
    }
  }

  void _saveCurrentPosition({bool completed = false}) {
    if (_hifzMode) return;

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
  Future<void> play() => _player.play();

  @override
  Future<void> pause() async {
    _pauseTimer?.cancel();
    _saveCurrentPosition();
    await _player.pause();
  }

  @override
  Future<void> stop() async {
    _pauseTimer?.cancel();
    _disableHifzMode();
    _saveCurrentPosition();
    await _player.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    if (_hifzMode) {
      _pauseTimer?.cancel();
      _advanceToNextAyah();
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
      final prevAyah = _memState.currentAyah - 1;
      if (prevAyah >= 1) {
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
