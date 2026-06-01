# 12 AI Agent Guide

This guide is optimized for AI agents. It maps tasks to specific file locations so you can find and modify the right code quickly.

---

## Task Index

| Task | Primary File(s) |
| :--- | :--- |
| Audio playback logic | `lib/features/player/services/audio_handler.dart` |
| Audio providers/state | `lib/features/player/providers/audio_provider.dart` |
| Full-screen player UI | `lib/features/player/screens/player_screen.dart` |
| Mini player UI | `lib/features/player/widgets/mini_player.dart` |
| Home screen | `lib/features/home/screens/home_screen.dart` |
| Surah list tile | `lib/features/home/widgets/surah_list_tile.dart` |
| Surah detail | `lib/features/surah/screens/surah_detail_screen.dart` |
| Favorites logic | `lib/features/player/providers/audio_provider.dart` (FavoritesNotifier) |
| Favorites UI | `lib/features/favorites/screens/favorites_screen.dart` |
| Playlists logic + UI | `lib/features/playlists/screens/playlists_screen.dart` |
| Alphabet grid UI | `lib/features/arabic_alphabet/screens/arabic_alphabet_screen.dart` |
| Letter detail UI | `lib/features/arabic_alphabet/screens/letter_detail_screen.dart` |
| Letter card widget | `lib/features/arabic_alphabet/widgets/letter_card.dart` |
| Search | `lib/features/search/screens/search_screen.dart` |
| Reciter bio | `lib/features/reciter/screens/reciter_info_screen.dart` |
| About screen | `lib/features/about/screens/about_screen.dart` |
| Support screen | `lib/features/support/screens/support_screen.dart` |
| Updates logic | `lib/features/updates/providers/update_provider.dart` |
| Updates UI | `lib/features/updates/screens/updates_screen.dart` |
| Update service | `lib/core/services/update_service.dart` |
| Routing | `lib/core/router/app_router.dart` |
| Theme / Colors | `lib/core/theme/app_theme.dart`, `app_colors.dart` |
| Typography | `lib/core/theme/app_typography.dart` |
| App constants | `lib/core/constants/app_constants.dart` |
| Duration helpers | `lib/core/utils/duration_helpers.dart` |
| Hive init | `lib/data/hive/hive_service.dart` |
| Juz Amma data | `lib/data/sources/juz_amma_data.dart` |
| Alphabet data | `lib/data/sources/arabic_alphabet_data.dart` |
| Models | `lib/data/models/audio_track.dart`, `surah.dart`, `arabic_letter.dart`, `playlist.dart`, `app_version.dart` |
| Repositories | `lib/data/repositories/quran_repository.dart`, `favorites_repository.dart`, `playlist_repository.dart`, `playback_repository.dart` |
| App entry point | `lib/main.dart` |
| App widget | `lib/app.dart` |

---

## Modifying Specific Features

### Modifying Audio Playback

**File:** `lib/features/player/services/audio_handler.dart`

- Add new playback controls (e.g., playback speed) → add method to `QuranAudioHandler`
- Change loop behavior → modify `_onTrackCompleted()` (line ~150)
- Change debounce timing → modify `_lastSkipTime` delta (line ~218, ~237)
- Change position save interval → modify `throttleTime` in constructor (line ~50)
- Add new audio features → extend `BaseAudioHandler` or add methods

### Modifying Audio State/Providers

**File:** `lib/features/player/providers/audio_provider.dart`

- Add new audio stream provider → add `StreamProvider` method (follow existing pattern at line ~31)
- Modify favorites logic → edit `FavoritesNotifier` class (line ~91)
- Change AudioService config → edit `initAudioService()` (line ~12)
- Access handler anywhere → `ref.watch(audioHandlerProvider)`

### Modifying the Player Screen UI

**File:** `lib/features/player/screens/player_screen.dart`

- Change layout → modify `build()` method
- Add new controls → add buttons in `_buildControls()` (line ~263)
- Change artwork display → modify `_buildSurahArt()` (line ~116)
- Change progress bar → modify `_buildProgressBar()` (line ~210)

### Modifying the Mini Player

**File:** `lib/features/player/widgets/mini_player.dart`

- Change appearance → modify `build()` method
- Add new controls → edit the Row in the `children:` list (line ~71)
- Change visibility logic → modify the `trackAsync.when()` pattern (line ~19)

### Modifying Home Screen

**File:** `lib/features/home/screens/home_screen.dart`

- Change quick actions → modify `_buildQuickAction` calls (line ~173)
- Modify drawer items → edit `_buildDrawer()` (line ~331)
- Change surah list behavior → edit the `SliverList` delegate (line ~249)
- The surah list tile widget is at `lib/features/home/widgets/surah_list_tile.dart`

### Modifying Favorites

- **UI:** `lib/features/favorites/screens/favorites_screen.dart`
- **Logic:** `FavoritesNotifier` in `lib/features/player/providers/audio_provider.dart`
- **Storage:** `lib/data/repositories/favorites_repository.dart`
- Favorites are stored as `List<String>` in Hive box `favorites`, key `favorite_tracks`

### Modifying Playlists

- **File:** `lib/features/playlists/screens/playlists_screen.dart` (all logic + UI inline)
- **Storage:** `lib/data/repositories/playlist_repository.dart`
- **Model:** `lib/data/models/playlist.dart`
- Playlists are stored as JSON strings in Hive box `playlists`, key = playlist ID

### Modifying Arabic Alphabet

- **Grid screen:** `lib/features/arabic_alphabet/screens/arabic_alphabet_screen.dart`
- **Letter detail:** `lib/features/arabic_alphabet/screens/letter_detail_screen.dart`
- **Card widget:** `lib/features/arabic_alphabet/widgets/letter_card.dart`
- **Data:** `lib/data/sources/arabic_alphabet_data.dart`
- **Audio uses:** `handler.loadLetterTracks()` — loads all 28 letters as a playlist

### Modifying Routing

**File:** `lib/core/router/app_router.dart`

- Add route → add `GoRoute(...)` to routes list, import the screen
- Change transition → modify `pageBuilder` to use `CustomTransitionPage`
- Add parameters → use `state.pathParameters['key']`

### Modifying Theme

- **Theme data:** `lib/core/theme/app_theme.dart` (darkTheme + lightTheme)
- **Colors:** `lib/core/theme/app_colors.dart`
- **Typography:** `lib/core/theme/app_typography.dart`

### Modifying App Constants

**File:** `lib/core/constants/app_constants.dart`

Contains: app name, version, reciter info, developer info, Hive box names, asset paths, URLs.

---

## Adding a New Feature

### Step-by-Step

1. **Create folder:** `lib/features/<feature_name>/`
2. **Create sub-folders:** `screens/`, `widgets/` (optional), `providers/` (optional)
3. **Add state management:**
   - If audio-related → use existing providers (`audioHandlerProvider`, etc.)
   - If new state → create `StateNotifier` or `StreamProvider`
4. **Add data model** (if needed) → `lib/data/models/<model>.dart`
5. **Add repository** (if needed) → `lib/data/repositories/<name>_repository.dart`
6. **Register route** → `lib/core/router/app_router.dart`
7. **Add to navigation** → HomeScreen drawer, quick actions, or other entry points
8. **Register new providers** (if any) — Riverpod handles this automatically

### Example: Adding "Recently Played" Feature

```dart
// 1. Model (lib/data/models/recently_played.dart)
class RecentlyPlayed { String trackId; DateTime lastPlayedAt; }

// 2. Repository (lib/data/repositories/recently_played_repository.dart)
// Store in Hive box 'settings' under 'recently_played' key

// 3. Provider (lib/features/recently/providers/recently_provider.dart)
final recentlyPlayedProvider = StateNotifierProvider<...>(...);

// 4. UI (lib/features/recently/screens/recently_screen.dart)
// Show list of recently played tracks

// 5. Route (lib/core/router/app_router.dart)
GoRoute(path: '/recently', ...)

// 6. In audio_handler.dart, update _saveCurrentPosition to also save to recently played
```

---

## Important Code Patterns

### Watching Audio State

```dart
// In any ConsumerWidget/ConsumerStatefulWidget:
final track = ref.watch(currentTrackProvider).valueOrNull;
final isPlaying = ref.watch(isPlayingProvider).valueOrNull ?? false;
final handler = ref.watch(audioHandlerProvider);
```

### Playing a Track

```dart
// From a list:
handler.loadTracks(JuzAmmaData.tracks, startIndex: index);

// Single audio:
handler.playSingleAsset(assetPath: '...', title: '...');

// Letter playlist:
handler.loadLetterTracks(letterTracks: letters, startIndex: 0);
```

### Toggling Favorites

```dart
ref.read(favoritesProvider.notifier).toggle(track.id);
```

### Checking if Track is Favorite

```dart
final favorites = ref.watch(favoritesProvider);
final isFav = favorites.contains(track.id);
```

### Navigating

```dart
context.push('/path');
context.push('/surah/78');
Navigator.pop(context);
```

---

## Data Model Relationships

```
AudioTrack
  ├── id: String          "juz_amma_078" | "letter_005"
  ├── surahNumber: int    78 | 0 (for alphabet)
  ├── assetPath: String   "assets/audio/juz_amma/078-an-naba.mp3"
  ├── trackType: String   "surah" | "alphabet"
  └── displayName: String "سورة النبأ" | "حرف الخاء"

Surah
  ├── number: int         78
  ├── nameArabic: String  "النبأ"
  └── pageStart: int      582

ArabicLetter
  ├── number: int         5
  ├── arabicLetter: String "ج"
  ├── makhrajGroup: String "اللسان"
  └── makhrajDetail: String "وسط اللسان مع وسط الحنك الأعلى"

Playlist
  ├── id: String          timestamp-based
  ├── name: String        user-defined
  └── trackIds: List<String>  references AudioTrack.id
```

## Hive Boxes Reference

| Box Name | Key Type | Value Type | Purpose |
| :--- | :--- | :--- | :--- |
| `playback_positions` | `String` (trackId) | `int` (ms) | Track position persistence |
| `favorites` | `String` ("favorite_tracks") | `List<String>` | Favorite track IDs |
| `playlists` | `String` (playlistId) | `String` (JSON) | Playlist serialization |
| `settings` | `String` (key) | `dynamic` | Misc settings (update check date) |

## File Dependency Graph

```
main.dart
  ├── app.dart
  │     └── app_router.dart (imports all screens)
  ├── hive_service.dart
  └── audio_provider.dart
        └── audio_handler.dart
              ├── audio_track.dart
              └── playback_repository.dart
                    └── hive_service.dart

home_screen.dart
  ├── juz_amma_data.dart → surah.dart, audio_track.dart
  ├── audio_provider.dart
  ├── mini_player.dart
  └── surah_list_tile.dart → surah.dart

player_screen.dart
  ├── audio_provider.dart
  ├── audio_handler.dart
  └── duration_helpers.dart

(Every screen that shows audio state imports audio_provider.dart)
```
