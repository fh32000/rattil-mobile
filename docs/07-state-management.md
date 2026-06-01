# 07 State Management

Warattilhu uses **Riverpod** (`flutter_riverpod`) exclusively for state management. There are 11 providers total, defined across 2 files.

## Provider Types Used

| Type | Usage | Count |
| :--- | :--- | :--- |
| `Provider` | Simple dependency injection (handler, repo) | 3 |
| `StreamProvider` | Reactive audio state streams | 8 |
| `StateNotifierProvider` | Mutable state (favorites, playlists, updates) | 3 |

## Provider File: `lib/features/player/providers/audio_provider.dart`

### Global Audio Handler Init

```dart
late QuranAudioHandler _audioHandler;

Future<void> initAudioService() async {
  _audioHandler = await AudioService.init(
    builder: () => QuranAudioHandler(),
    config: AudioServiceConfig(/* ... */),
  );
}
```

Called once in `main.dart` before `runApp()`.

### 1. `audioHandlerProvider` (Provider)

```dart
final audioHandlerProvider = Provider<QuranAudioHandler>((ref) {
  return _audioHandler;
});
```

**Purpose:** Provides the single `QuranAudioHandler` instance to the entire app.

### 2. `currentTrackProvider` (StreamProvider)

```dart
final currentTrackProvider = StreamProvider<AudioTrack?>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return Rx.combineLatest2(
    handler.trackListStream,
    handler.currentIndexStream,
    (tracks, index) => /* ... */,
  );
});
```

**Purpose:** Combines the track list and current index into a single `AudioTrack?` stream.

### 3. `isPlayingProvider` (StreamProvider)

```dart
final isPlayingProvider = StreamProvider<bool>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.playbackState.map((state) => state.playing).distinct();
});
```

### 4-7. Position/Duration/Buffered/Loop Providers

```dart
final positionProvider       = StreamProvider<Duration>((ref) /* positionStream */);
final durationProvider       = StreamProvider<Duration?>((ref) /* durationStream */);
final bufferedPositionProvider = StreamProvider<Duration>((ref) /* bufferedPositionStream */);
final loopModeProvider       = StreamProvider<LoopMode>((ref) /* loopModeStream */);
```

### 8. `trackListProvider` (StreamProvider)

```dart
final trackListProvider = StreamProvider<List<AudioTrack>>((ref) /* trackListStream */);
```

### 9. `currentIndexProvider` (StreamProvider)

```dart
final currentIndexProvider = StreamProvider<int>((ref) /* currentIndexStream */);
```

### 10. `favoritesProvider` (StateNotifierProvider)

```dart
class FavoritesNotifier extends StateNotifier<Set<String>> {
  final FavoritesRepository _repo;
  FavoritesNotifier(this._repo) : super(_repo.getAllFavorites().toSet());

  void toggle(String trackId) {
    _repo.toggleFavorite(trackId);
    state = _repo.getAllFavorites().toSet();
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  final repo = ref.watch(favoritesRepositoryProvider);
  return FavoritesNotifier(repo);
});
```

### 11. `favoritesRepositoryProvider` (Provider)

```dart
final favoritesRepositoryProvider = Provider((ref) => FavoritesRepository());
```

## Provider File: `lib/features/updates/providers/update_provider.dart`

### Update Provider

```dart
enum UpdateStatus { initial, checking, updateAvailable, upToDate, error }

class UpdateState { /* status, latestVersion, currentVersionStr */ }

final updateProvider = StateNotifierProvider<UpdateNotifier, UpdateState>((ref) {
  return UpdateNotifier(UpdateService());
});
```

**Methods:** `checkForUpdates({bool isSilent})` — silent = once-per-day check.

## Inline Providers in `lib/features/playlists/screens/playlists_screen.dart`

### Playlist Providers (defined within the screen file)

```dart
final playlistRepoProvider = Provider((ref) => PlaylistRepository());

final playlistsProvider =
    StateNotifierProvider<PlaylistsNotifier, List<Playlist>>((ref) {
  return PlaylistsNotifier(ref.watch(playlistRepoProvider));
});
```

## Data Flow Pattern

```
Widget
  │ ref.watch(provider)
  ▼
Provider (Riverpod)
  │ holds instance of Service/Repository
  ▼
Service / Repository
  │ reads/writes
  ▼
Data Source (Hive / Static Data)
  │ returns result
  ▼
Provider emits new state
  │
  ▼
Widget rebuilds
```

## Key Pattern: Stream-Based Audio State

Audio providers are `StreamProvider` because `Just Audio` exposes continuous streams (position, playing state, duration). This is a natural fit — the UI reacts to audio changes without polling.

## Key Pattern: StateNotifier for Mutable Data

- **Favorites** (`Set<String>`) — toggling adds/removes IDs
- **Playlists** (`List<Playlist>`) — CRUD operations
- **UpdateState** — status machine with copyWith

## Local State

Some screens use plain `setState()` for UI-only state:
- `SearchScreen` — search query text, filter selection, results list
- `ArabicAlphabetScreen` — selected makhraj group
- `LetterDetailScreen` — current letter number (prev/next navigation)
- `SupportScreen` — form fields, issue type dropdown
