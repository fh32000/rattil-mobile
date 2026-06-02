# 05 Features Documentation

This document details every feature in the app, its files, state management, routing, and data flow.

---

## 1. Home Screen

| | |
| :--- | :--- |
| **Goal** | Main dashboard showing Juz Amma surah list |
| **File** | `lib/features/home/screens/home_screen.dart` |
| **State** | `currentTrackProvider`, `isPlayingProvider`, `updateProvider` (all from other features) |
| **Routing** | `/` (initial route) |
| **Data Source** | `JuzAmmaData.surahs` (static constant) |

**Components:**
- `SliverAppBar` — gradient header with app icon, "جزء عمّ" badge, search button
- Quick action row — 4 buttons: Favorites, Playlists, Reciter, Alphabet
- `SurahListTile` — list of all surahs with play/pause per row
- `_buildDrawer()` — navigation drawer with 8 items (home, favorites, playlists, reciter, alphabet, updates, about, support)
- `MiniPlayer` — always present at bottom via `Positioned` in `Stack`

**Interaction:** Tapping play on a surah calls `handler.loadTracks(JuzAmmaData.tracks, startIndex: index)`.

---

## 2. Audio Player (Full-Screen)

| | |
| :--- | :--- |
| **Goal** | Full-screen audio player with controls |
| **File** | `lib/features/player/screens/player_screen.dart` |
| **State** | `currentTrackProvider`, `isPlayingProvider`, `positionProvider`, `durationProvider`, `loopModeProvider`, `favoritesProvider` |
| **Routing** | `/player` (slide-up transition via `CustomTransitionPage`) |
| **Entry** | Tapping the MiniPlayer |

**Controls:**
- Play/Pause (gradient circle button)
- Skip Previous / Skip Next (with debounce)
- Rewind 10s / Forward 10s
- Loop toggle: off → one → all → off
- Favorite heart toggle
- Seek slider
- Position/duration labels

**UI:** Gradient background, surah artwork box (shows name, page number for surahs, "حرف" for alphabet tracks), reciter name.

---

## 3. Mini Player

| | |
| :--- | :--- |
| **Goal** | Persistent floating bottom bar |
| **File** | `lib/features/player/widgets/mini_player.dart` |
| **State** | `currentTrackProvider`, `isPlayingProvider`, `positionProvider`, `durationProvider` |
| **Visibility** | Auto-hides when no track is loaded |

**Features:**
- Thin progress bar at top
- Track display name + reciter + position
- Skip Previous / Play-Pause / Skip Next buttons
- Tap opens full PlayerScreen via `context.push('/player')`

---

## 4. Favorites

| | |
| :--- | :--- |
| **Goal** | Save and view favorite tracks |
| **Files** | `lib/features/favorites/screens/favorites_screen.dart`, `lib/features/player/providers/audio_provider.dart` (FavoritesNotifier) |
| **State** | `favoritesProvider` — `StateNotifierProvider<FavoritesNotifier, Set<String>>` |
| **Data Source** | `FavoritesRepository` backed by Hive box `favorites` |
| **Routing** | `/favorites` |

**Operations:**
- Toggle: `ref.read(favoritesProvider.notifier).toggle(track.id)`
- Swipe to remove (Dismissible widget)
- Empty state illustration
- Tap to play all favorites starting from tapped track

**Storage:** `List<String>` of track IDs in Hive box `favorites` under key `favorite_tracks`.

---

## 5. Playlists

| | |
| :--- | :--- |
| **Goal** | Create and manage custom playlists |
| **File** | `lib/features/playlists/screens/playlists_screen.dart` |
| **State** | `playlistsProvider` — `StateNotifierProvider<PlaylistsNotifier, List<Playlist>>` (inline in file) |
| **Data Source** | `PlaylistRepository` — Hive box `playlists`, serialized as JSON |
| **Routing** | `/playlists` |

**Operations:**
- Create playlist (AlertDialog with name input)
- Delete playlist (swipe or button)
- View playlist detail (DraggableScrollableSheet bottom sheet)
- Add tracks (another bottom sheet with available tracks)
- Remove tracks from playlist
- Play all tracks in playlist

**Model:** `Playlist` — `id`, `name`, `trackIds`, `createdAt`, with `toJson`/`fromJson`.

---

## 6. Search

| | |
| :--- | :--- |
| **Goal** | Search surahs by name, number, or page |
| **File** | `lib/features/search/screens/search_screen.dart` |
| **State** | Local `State.setState()` — no Riverpod needed |
| **Data Source** | `JuzAmmaData.surahs` filtered in-memory |
| **Routing** | `/search` |

**Search criteria:** Arabic name, English name, surah number, page number.  
**Filters:** All / Meccan (مكية) / Medinan (مدنية).  
**Actions:** Tap to go to SurahDetailScreen, play button to start from that surah.

---

## 7. Surah Detail

| | |
| :--- | :--- |
| **Goal** | Show surah information and play controls |
| **File** | `lib/features/surah/screens/surah_detail_screen.dart` |
| **Routing** | `/surah/:surahNumber` |

**Components:**
- Gradient header with surah number circle
- Info cards: number, verses count, page number
- Revelation type badge
- "تشغيل السورة" button (loads all Juz Amma tracks starting at this surah)
- Favorite toggle
- MiniPlayer at bottom

---

## 8. Arabic Alphabet

| | |
| :--- | :--- |
| **Goal** | Educational tool for 28 Arabic letters with makhraj groups |
| **Files** | `lib/features/arabic_alphabet/screens/arabic_alphabet_screen.dart`, `letter_detail_screen.dart`, `widgets/letter_card.dart` |
| **Data Source** | `ArabicAlphabetData` (static, 28 letters) |
| **Routing** | `/arabic-alphabet`, `/arabic-alphabet/:number` |

**Alphabet Screen:**
- Gradient header with "مخارج الحروف"
- Makhraj group filter chips: الكل, الحلق, اللسان, الشفتان
- Color legend: blue (throat), teal (tongue), purple (lips)
- 4-column grid of LetterCard widgets
- Each card shows: letter glyph, name, play/pause button
- Playing letters use `handler.loadLetterTracks()` (loads all 28 as a playlist)

**Letter Detail Screen:**
- Giant animated letter (100px) with group-color gradient
- Makhraj info card (group badge + detailed description)
- Audio playback button with "الاستشهاد الصوتي" label
- Prev/Next navigation buttons

---

## 9. Reciter Info

| | |
| :--- | :--- |
| **Goal** | Display reciter biography |
| **File** | `lib/features/reciter/screens/reciter_info_screen.dart` |
| **Routing** | `/reciter` |

**Content:** Reciter name, bio, location, university, specialization, content type.  
**Data:** From `AppConstants` (reciterName, reciterBio).

---

## 10. About

| | |
| :--- | :--- |
| **Goal** | App information and developer contact |
| **File** | `lib/features/about/screens/about_screen.dart` |
| **Routing** | `/about` |

**Content:** App logo, name, version, description, goals, developer info, contact tiles (email, WhatsApp, phone) via `url_launcher`.

---

## 11. Support

| | |
| :--- | :--- |
| **Goal** | Issue reporting form and contact |
| **File** | `lib/features/support/screens/support_screen.dart` |
| **Routing** | `/support` |

**Form:** Issue type dropdown (5 types) + description text field → sends via WhatsApp.  
**Contact:** WhatsApp, Phone, Email tiles.

---

## 12. Updates

| | |
| :--- | :--- |
| **Goal** | Check for new app versions |
| **Files** | `lib/features/updates/providers/update_provider.dart`, `screens/updates_screen.dart` |
| **State** | `updateProvider` — `StateNotifierProvider<UpdateNotifier, UpdateState>` |
| **Service** | `UpdateService` fetches `https://woostore.dev/apps/rattil/version.json` |
| **Routing** | `/updates` |

**States:** initial → checking → (updateAvailable | upToDate | error).  
**Silent check:** On HomeScreen init, checks once per day (tracked in Hive `settings` box).

---

## 13. Hifz Memorization Mode

| | |
| :--- | :--- |
| **Goal** | Ayah-by-ayah memorization tool with configurable repetition, recitation pause, verse display, and persistent settings |
| **Files** | `audio_handler.dart` (engine), `memorization_settings.dart` (model), `memorization_settings_repository.dart` (persistence), `ayah_track_source.dart` (data source), `ayah_file_to_verse.dart` (mapping), `verse_service.dart` (verse text), `audio_loader.dart` (web audio), `verse_display_widget.dart`, `hifz_mode_indicator.dart`, `hifz_progress_bar.dart`, `pause_countdown_bar.dart`, `volume_control.dart`, `playback_speed_control.dart`, `hifz_dashboard.dart`, `mini_player.dart` |
| **State** | `memorizationSettingsProvider`, `memorizationPlaybackStateProvider`, `canEnableHifzModeProvider`, `isHifzModeActiveProvider` (all StreamProvider) |
| **Routing** | No dedicated route — toggled within PlayerScreen |
| **Entry** | Hifz toggle button in PlayerScreen (visible when current surah has ayah audio) |

### How It Works

```
Normal surah playback
        │
        ▼  User toggles "وضع الحفظ"
        │
        ▼
enableHifzMode()
  ├── Save current playlist/index → _savedTrackList, _savedTrackIndex
  ├── Load ayah tracks for this surah → _ayahTracks
  ├── Replace track list with ayah tracks
  └── Start playback from ayah 1
        │
        ▼
  ┌──────────────────────────────────┐
  │     Hifz Playback Loop           │
  │                                  │
  │  _playAyah(ayahNumber)           │
  │    → setAudioSource(ayah MP3)    │
  │    → apply speed & volume        │
  │    → play                        │
  │         │                        │
  │         ▼                        │
  │  _handleAyahCompleted()          │
  │    ├── Basmala check: if surah≠1 │
  │    │   and ayah==1 → repCount=1  │
  │    ├── More repetitions? →       │
  │    │   _scheduleNextPlayback()   │
  │    ├── Last repetition? →        │
  │    │   advance to next ayah      │
  │    │   (with pause if enabled)   │
  │    └── Last ayah? →              │
  │        _handleSurahComplete()    │
  │            ├── repeatSurah? →    │
  │            │   restart from ayah1│
  │            └── restore playlist  │
  │                → next surah      │
  └──────────────────────────────────┘
```

### State Machine

```
HifzPhase.listening ── ayah ends ──► HifzPhase.reciting
      ▲                                    │
      │                                    │ pause timer ends
      │                                    │
      └────────────── play() ◄─────────────┘
```

- **Listening:** Audio plays, user listens.
- **Reciting:** Audio paused for `(ayahDuration / playbackSpeed × recitationMultiplier)` duration; user recites aloud.

### Memorization Settings (Persisted)

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `ayahRepeatCount` | `int` | 3 | Number of times each ayah repeats |
| `pauseForRecitation` | `bool` | true | Pause between replays for user to recite |
| `repeatSurah` | `bool` | false | Loop entire surah when all ayat done |
| `volume` | `double` | 1.0 | Playback volume (0.0-1.0) |
| `playbackSpeed` | `double` | 1.0 | Speed multiplier (0.75x-2.0x) |
| `recitationMultiplier` | `double` | 1.0 | Scale pause duration (0.25x-1.0x) |
| `hideVerses` | `bool` | false | Hide verse text for memorization testing |

Settings are loaded from Hive on app start and saved immediately on every change.

### Basmala Special Handling

- **Non-Fatihah surahs:** Basmala (ayah 1) plays only once, regardless of `ayahRepeatCount`. Recitation pause still applies.
- **Al-Fatihah:** Basmala follows normal repetition rules (treated as an actual verse).

Detection logic uses surah number + ayah index — no text matching.

### Verse Display

In Hifz mode, the surah artwork area is replaced by `VerseDisplayWidget` showing:
- **Previous ayah** (dimmed, 55% opacity, 20px)
- **Current ayah** (gold, bold, 28px) — highlighted with `AnimatedSwitcher` (400ms transition)
- **Next ayah** (dimmed, 55% opacity, 20px)
- **Hidden mode:** When `hideVerses=true`, shows placeholder text:
  - 👂 استمع للآية (listening phase)
  - 👄 ردد الآية الآن (reciting phase)

Verse text is fetched via `VerseService` (singleton wrapping the `quran` package with LRU cache).

### Audio Data Source

Ayah-level MP3 files are stored in `assets/audio/juz_amma_ayahs/surah_{NNN}/{NNN}.mp3`. The `AyahTrackSource` class maps each surah to its actual file count (e.g., surah 78 → 44 files). Each surah has one extra file (file index 1) for the basmala.

### Skip Behavior

- **Skip Next:** Cancels any active pause, advances to next ayah, resets repetition counter.
- **Skip Previous:** Cancels pause, goes to previous ayah, resets repetition.
- **Position persistence is disabled** in Hifz mode (saving positions for individual ayah files is meaningless given the repetition structure).

### Exiting Hifz Mode

On `disableHifzMode()`:
1. Pause timers are cancelled
2. Ayah tracks cleared
3. Legacy track list and index restored
4. Normal surah playback resumes

### Web Support

`AudioLoader.createSource()` strips the `assets/` prefix on web to avoid double-path issues, using `AudioSource.asset` which internally converts to a base64 data URL.
