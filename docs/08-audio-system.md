# 08 Audio System

The audio system is the most critical part of Warattilhu. It uses **Just Audio** for playback and **Audio Service** for OS integration (background, lock screen, notifications).

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Audio Service                         │
│  QuranAudioHandler extends BaseAudioHandler              │
│  with SeekHandler, QueueHandler                          │
│                                                          │
│  ┌─────────────────────────────────────┐                │
│  │         Just Audio Engine            │                │
│  │  AudioPlayer _player                 │                │
│  │  - setAsset(assetPath)              │  ← Local MP3   │
│  │  - play() / pause() / seek() / stop()│                │
│  │  - playbackEventStream              │  ← Position     │
│  │  - processingStateStream            │  ← Completion    │
│  │  - positionStream                   │  ← Every 200ms   │
│  └─────────────────────────────────────┘                │
│                                                          │
│  Internal State:                                         │
│  - BehaviorSubject<List<AudioTrack>> _trackList          │
│  - BehaviorSubject<int> _currentIndex                    │
│  - BehaviorSubject<LoopMode> _loopMode                   │
│  - PlaybackRepository (Hive position persistence)        │
└─────────────────────┬───────────────────────────────────┘
                      │ streams exposed via getters
                      ▼
┌─────────────────────────────────────────────────────────┐
│              Riverpod StreamProviders                     │
│  currentTrackProvider  │  isPlayingProvider                │
│  positionProvider      │  durationProvider                 │
│  loopModeProvider      │  trackListProvider               │
│  currentIndexProvider  │  bufferedPositionProvider         │
└─────────────────────┬────────────────────────────────────┘
                      │ ref.watch()
                      ▼
┌─────────────────────────────────────────────────────────┐
│                    UI Layer                               │
│  PlayerScreen  │  MiniPlayer  │  HomeScreen               │
│  SurahDetail   │  AlphabetScreen  │  FavoritesScreen     │
│  SearchScreen  │  PlaylistsScreen                         │
└─────────────────────────────────────────────────────────┘
```

## Key File: `lib/features/player/services/audio_handler.dart`

### Class: `QuranAudioHandler`

```dart
class QuranAudioHandler extends BaseAudioHandler
    with SeekHandler, QueueHandler {
  final AudioPlayer _player = AudioPlayer();
  final PlaybackRepository _playbackRepo = PlaybackRepository();
  // ...
}
```

### Initialization (Constructor)

1. Pipes `_player.playbackEventStream` → `playbackState` via `_transformEvent()`
2. Listens to `processingStateStream` for track completion → calls `_onTrackCompleted()`
3. Listens to `positionStream` (throttled to 3s) → saves position to Hive

### Core Methods

| Method | Description |
| :--- | :--- |
| `loadTracks(tracks, {startIndex})` | Load list of tracks, build media queue, start playing from index |
| `playSingleAsset(assetPath, title)` | Play a single file (used for alphabet letters) |
| `loadLetterTracks(letterTracks, startIndex)` | Play letter playlist from index |
| `_loadCurrentTrack()` | Set asset, restore saved position, play |
| `_onTrackCompleted()` | Handle loop/repeat behavior on track end |
| `cycleLoopMode()` | off → one → all → off |
| `fastForward10()` / `rewind10()` | Skip by 10 seconds |
| `skipToNext()` / `skipToPrevious()` | Next/prev with 500ms debounce |

### Loop Behavior

| Mode | On Track Complete |
| :--- | :--- |
| `LoopMode.off` | Skip to next if available, else stop |
| `LoopMode.one` | Replay current track from start |
| `LoopMode.all` | Skip to next; if last, wrap to first |

### Debounce

Skip buttons are debounced at 500ms to prevent rapid-fire presses causing audio glitches.

### Playback Position Persistence

- Saves position to Hive every 3 seconds via `_player.positionStream.throttleTime(3s)`
- Restores position when a track is loaded (`_player.seek(savedPosition)`)
- Clears position to 0 on track completion

### MediaItem Mapping

```dart
MediaItem _trackToMediaItem(AudioTrack track) {
  return MediaItem(
    id: track.id,
    title: track.displayName,   // "سورة النبأ" or "حرف الخاء"
    artist: track.reciterName,
    album: 'جزء عمّ',
    extras: { 'surahNumber': ..., 'pageNumber': ... },
  );
}
```

### PlaybackState Transformation

`_transformEvent()` maps Just Audio's internal `ProcessingState` to Audio Service's `AudioProcessingState` and exposes controls (skipPrev, play/pause, skipNext).

## Audio Service Config

Defined in `lib/features/player/providers/audio_provider.dart`:

```dart
AudioServiceConfig(
  androidNotificationChannelId: 'com.rattil.audio',
  androidNotificationChannelName: 'ورتِّله',
  androidNotificationOngoing: true,
  androidStopForegroundOnPause: true,
)
```

## App Startup Flow

```
main()
  │
  ├── HiveService.init()         ← Open 4 Hive boxes
  │
  └── initAudioService()         ← Create QuranAudioHandler via AudioService.init()
        │
        └── AudioService.init(   ← Register background service
              builder: () => QuranAudioHandler(),
              config: ...
            )
```

## Asset-Based Audio

All audio is bundled as local assets (no streaming):

- **Juz Amma:** `assets/audio/juz_amma/{number}-{name}.mp3` (e.g., `078-an-naba.mp3`)
- **Alphabet:** `assets/audio/arabic_alphabet/{number}-{name}.mp3` (e.g., `001-alif.mp3`)
- Files are ~64kbps mono MP3 for size optimization
- Total: ~49 MB for 66 files

## Background Playback Flow

```
App minimized → Audio continues (AudioService handles)
  │
Lock screen → OS MediaSession displays:
  ├── Title: "سورة النبأ"
  ├── Artist: "عمر أحمد عمر الخامر"
  ├── Album: "جزء عمّ"
  ├── Controls: Previous, Play/Pause, Next
  │
App reopened → MiniPlayer shows current state
```

## Key Observations

- **Single player instance** — only one `AudioPlayer` for both surahs and letters
- **Alphabet tracks** are loaded as a playlist (letter 1-28) using `loadLetterTracks`
- **No remote audio** — all files are bundled assets
- **No audio caching** needed since files are local
