# 04 Folder Structure

## Complete Tree

```
rattil-mobile/
├── android/                          # Android native project
├── ios/                              # iOS native project
├── web/                              # Web entry point
├── assets/
│   ├── audio/
│   │   ├── juz_amma/                 # 38 MP3 files (Al-Fatihah + Surahs 78-114)
│   │   ├── juz_amma_ayahs/           # 585 ayah-level MP3 files across 33 surahs (78-114)
│   │   │   ├── surah_078/            # 44 ayah files (001.mp3 - 044.mp3)
│   │   │   ├── surah_079/            # 46 ayah files
│   │   │   ├── ...                   # Surahs 080-114
│   │   │   └── surah_114/            # 7 ayah files
│   │   └── arabic_alphabet/          # 28 MP3 files (letters أ to ي)
│   ├── images/
│   │   └── app_icon.png              # App icon (used in About, Home, Drawer)
│   ├── fonts/
│   │   └── .gitkeep
│   └── screenshots/                  # Screenshots for README
│
├── lib/
│   ├── main.dart                     # Entry: Hive init → AudioService init → runApp
│   ├── app.dart                      # RattilApp: MaterialApp.router with dark theme, RTL
│   │
│   ├── core/                         # Cross-cutting concerns
│   │   ├── constants/
│   │   │   └── app_constants.dart    # App metadata, reciter info, Hive box names, asset paths
│   │   ├── router/
│   │   │   └── app_router.dart       # GoRouter: 12 routes, custom transitions
│   │   ├── services/
│   │   │   └── update_service.dart   # Fetches version.json for update checking
│   │   ├── theme/
│   │   │   ├── app_colors.dart       # Color palette (teal, gold, dark surfaces)
│   │   │   ├── app_theme.dart        # Dark + Light ThemeData definitions
│   │   │   └── app_typography.dart   # Amiri + Cairo font config
│   │   └── utils/
│   │       └── duration_helpers.dart  # formatDuration(), formatMilliseconds()
│   │
│   ├── data/                         # Data models, sources, repositories
│   │   ├── hive/
│   │   │   └── hive_service.dart     # Hive initialization, 4 box getters
│   │   ├── models/
│   │   │   ├── audio_track.dart      # AudioTrack: id, surahNumber, assetPath, trackType (includes 'ayah'), ayahNumber
│   │   │   ├── surah.dart            # Surah: number, nameArabic/English, versesCount, pageStart
│   │   │   ├── arabic_letter.dart    # ArabicLetter: number, letter, makhrajGroup/Detail
│   │   │   ├── playlist.dart         # Playlist: id, name, trackIds, createdAt
│   │   │   ├── memorization_settings.dart  # MemorizationSettings, MemorizationPlaybackState, HifzPhase enum
│   │   │   └── app_version.dart      # AppVersion: parsed from remote JSON
│   │   ├── repositories/
│   │   │   ├── quran_repository.dart # Wraps JuzAmmaData static access + search, ayah audio helpers
│   │   │   ├── favorites_repository.dart  # Hive-backed CRUD for favorites
│   │   │   ├── playlist_repository.dart   # Hive-backed CRUD for playlists
│   │   │   ├── playback_repository.dart   # Hive-backed position save/restore
│   │   │   └── memorization_settings_repository.dart  # Hive-backed JSON persistence
│   │   └── sources/
│   │       ├── juz_amma_data.dart    # Static list of 38 surahs + tracks getter
│   │       ├── arabic_alphabet_data.dart  # Static list of 28 letters + group filter
│   │       ├── ayah_track_source.dart     # Surah→ayah file count map, ayah AudioTrack generation
│   │       └── ayah_file_to_verse.dart    # Audio index → canonical verse number mapping (with basmala offset)
│   │
│   └── features/                     # Feature modules (11 total)
│       ├── home/                     # Main dashboard
│       │   ├── screens/
│       │   │   └── home_screen.dart  # SliverAppBar, quick actions, surah list, drawer, mini-player
│       │   └── widgets/
│       │       └── surah_list_tile.dart  # Single surah row with play/pause button
│       │
│       ├── player/                   # Audio player (core feature)
│       │   ├── services/
│       │   │   ├── audio_handler.dart    # QuranAudioHandler: playback, queue, loop, seek + Hifz engine (ayah repetition, pause countdown, basmala handling)
│       │   │   ├── audio_loader.dart     # Platform-aware AudioSource factory (handles web asset path)
│       │   │   └── verse_service.dart    # Singleton: Quran verse text fetching with LRU cache
│       │   ├── providers/
│       │   │   └── audio_provider.dart   # 12 providers (8 legacy + 4 Hifz) + FavoritesNotifier + initAudioService()
│       │   ├── screens/
│       │   │   └── player_screen.dart    # Full-screen player: artwork/progress/controls + Hifz toggle, VerseDisplayWidget, memorization settings panel
│       │   └── widgets/
│       │       ├── mini_player.dart      # Persistent bottom bar + Hifz-aware ayah progress
│       │       ├── verse_display_widget.dart  # Green gradient card: prev/current/next ayah with hide-verses placeholder
│       │       ├── hifz_mode_indicator.dart   # Animated pulsing badge: Listening/Reciting phase
│       │       ├── hifz_progress_bar.dart     # Ayah-level progress bar through surah
│       │       ├── pause_countdown_bar.dart   # Orange countdown bar during recitation pause
│       │       ├── volume_control.dart        # Volume slider for Hifz mode
│       │       ├── playback_speed_control.dart # Speed chip selector (0.75x-2.0x)
│       │       └── hifz_dashboard.dart        # Info card: surah, ayah, repetition, speed, phase
│       │
│       ├── surah/                    # Surah detail page
│       │   └── screens/
│       │       └── surah_detail_screen.dart  # Info cards + play section + mini-player
│       │
│       ├── arabic_alphabet/          # Alphabet learning tool
│       │   ├── screens/
│       │   │   ├── arabic_alphabet_screen.dart  # Gallery grid with makhraj group filter
│       │   │   └── letter_detail_screen.dart    # Single letter: giant glyph, makhraj info, audio
│       │   └── widgets/
│       │       └── letter_card.dart             # Grid card with colored border, play button
│       │
│       ├── favorites/                # Favorites screen
│       │   └── screens/
│       │       └── favorites_screen.dart  # List of favorite tracks, swipe to remove
│       │
│       ├── playlists/                # Playlist management
│       │   └── screens/
│       │       └── playlists_screen.dart  # CRUD, create dialog, bottom sheet detail + add tracks
│       │
│       ├── search/                   # Search screen
│       │   └── screens/
│       │       └── search_screen.dart     # Text field + Meccan/Medinan filter + results
│       │
│       ├── reciter/                  # Reciter biography
│       │   └── screens/
│       │       └── reciter_info_screen.dart  # Bio, location, education, specialization
│       │
│       ├── about/                    # App info
│       │   └── screens/
│       │       └── about_screen.dart  # App description, developer info, contact buttons
│       │
│       ├── support/                  # Support/feedback
│       │   └── screens/
│       │       └── support_screen.dart  # Issue form → WhatsApp, contact tiles
│       │
│       └── updates/                  # Version update checker
│           ├── providers/
│           │   └── update_provider.dart  # UpdateNotifier, UpdateState, four statuses
│           └── screens/
│               └── updates_screen.dart   # Current version, update card, download button
│
├── test/                             # Test files
├── pubspec.yaml                      # Dependencies, assets declaration
├── README.md                         # Project README (Arabic)
└── docs/                             # This documentation
```

## Directory Responsibilities

### `lib/core/`
**Responsibility:** Global configurations, theme, constants, shared utilities.  
**Modify when:** Changing app-wide styles, colors, fonts, routing, constants, or adding new services.  
**Key files:** `app_router.dart`, `app_theme.dart`, `app_colors.dart`, `app_constants.dart`.

### `lib/data/`
**Responsibility:** All data models, static data sources, Hive persistence layer, and repositories.  
**Modify when:** Adding new data models, changing storage logic, adding new surah/letter data.  
**Key files:** `juz_amma_data.dart`, `arabic_alphabet_data.dart`, `hive_service.dart`, all `_repository.dart`.

### `lib/features/`
**Responsibility:** Self-contained feature modules. Each folder represents a feature with its own UI, providers, and services.  
**Modify when:** Adding/editing app functionality. Create new folders here for new features.  
**Sub-folder convention:**
- `screens/` — page-level widgets
- `widgets/` — reusable sub-widgets
- `providers/` — Riverpod providers (if feature has its own state)
- `services/` — business logic classes (if feature has its own)

### `assets/`
**Responsibility:** Bundled audio files, images, fonts.  
**Modify when:** Adding new surah/letter recordings, changing app icon, adding new assets.  
**Note:** Must register new assets in `pubspec.yaml` under `flutter:` → `assets:`.

## File Count Summary

| Directory | Files |
| :--- | :--- |
| `lib/core/` | 7 |
| `lib/data/` | 16 |
| `lib/features/` | 26 |
| **Total `lib/`** | **49 Dart files** |
