import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import '../../../data/models/audio_track.dart';
import '../../../data/repositories/playback_repository.dart';

/// Audio handler for background playback and media controls
class QuranAudioHandler extends BaseAudioHandler with SeekHandler, QueueHandler {
  final AudioPlayer _player = AudioPlayer();
  final PlaybackRepository _playbackRepo = PlaybackRepository();

  final BehaviorSubject<List<AudioTrack>> _trackList =
      BehaviorSubject.seeded([]);
  final BehaviorSubject<int> _currentIndex = BehaviorSubject.seeded(0);
  final BehaviorSubject<LoopMode> _loopMode =
      BehaviorSubject.seeded(LoopMode.off);

  AudioPlayer get player => _player;
  Stream<List<AudioTrack>> get trackListStream => _trackList.stream;
  Stream<int> get currentIndexStream => _currentIndex.stream;
  Stream<LoopMode> get loopModeStream => _loopMode.stream;

  List<AudioTrack> get currentTrackList => _trackList.value;
  int get currentIndex => _currentIndex.value;
  AudioTrack? get currentTrack {
    final tracks = _trackList.value;
    final idx = _currentIndex.value;
    if (tracks.isEmpty || idx < 0 || idx >= tracks.length) return null;
    return tracks[idx];
  }

  LoopMode get currentLoopMode => _loopMode.value;

  QuranAudioHandler() {
    // Broadcast player state changes to audio_service
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);

    // Handle track completion
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _onTrackCompleted();
      }
    });

    // Save position periodically
    _player.positionStream
        .throttleTime(const Duration(seconds: 3))
        .listen((position) {
      _saveCurrentPosition();
    });
  }

  /// Load a list of tracks and start playing from the given index
  Future<void> loadTracks(List<AudioTrack> tracks, {int startIndex = 0}) async {
    if (tracks.isEmpty) return;

    _trackList.add(tracks);
    _currentIndex.add(startIndex);

    // Build queue for media notification
    queue.add(tracks.map(_trackToMediaItem).toList());

    await _loadCurrentTrack();
  }

  /// Load and play the current track
  Future<void> _loadCurrentTrack() async {
    final track = currentTrack;
    if (track == null) return;

    // Update media item for notification
    mediaItem.add(_trackToMediaItem(track));

    try {
      await _player.setAsset(track.assetPath);

      // Restore saved position
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

  void _onTrackCompleted() {
    _saveCurrentPosition(completed: true);

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
    final track = currentTrack;
    if (track == null) return;

    if (completed) {
      _playbackRepo.savePosition(track.id, 0);
    } else {
      _playbackRepo.savePosition(
        track.id,
        _player.position.inMilliseconds,
      );
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
    _saveCurrentPosition();
    await _player.pause();
  }

  @override
  Future<void> stop() async {
    _saveCurrentPosition();
    await _player.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
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
    await _player.seek(
      newPosition > duration ? duration : newPosition,
    );
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
      title: 'سورة ${track.surahNameArabic}',
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
    _saveCurrentPosition();
    await _player.dispose();
    await _trackList.close();
    await _currentIndex.close();
    await _loopMode.close();
  }
}

/// Loop mode enum matching just_audio
enum LoopMode { off, one, all }
