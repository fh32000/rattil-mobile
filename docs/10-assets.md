# 10 Assets

## Directory Structure

```
assets/
├── audio/
│   ├── juz_amma/              # 38 MP3 files (~49 MB total, 64kbps mono)
│   │   ├── 001-al-fatihah.mp3   # Al-Fatihah (Surah 1)
│   │   ├── 078-an-naba.mp3      # Surah An-Naba (Surah 78)
│   │   ├── 079-an-naziat.mp3    # Surah An-Naziat
│   │   ├── ...                  # Surahs 80-113
│   │   └── 114-an-nas.mp3       # Surah An-Nas (Surah 114)
│   │
│   ├── juz_amma_ayahs/        # 585 ayah-level MP3 files (~170 MB) for Hifz mode
│   │   ├── surah_078/           # 44 files (001.mp3 = basmala, 002-044 = ayat)
│   │   ├── surah_079/           # 46 files
│   │   ├── ...                  # Surahs 080-113 (each with basmala + ayat)
│   │   └── surah_114/           # 7 files
│   │
│   └── arabic_alphabet/       # 28 MP3 files
│       ├── 001-alif.mp3         # Letter Alif
│       ├── 002-baa.mp3          # Letter Baa
│       ├── 003-taa.mp3          # Letter Taa
│       ├── ...                  # Letters 4-27
│       └── 028-yaa.mp3          # Letter Yaa
│
├── images/
│   ├── app_icon.png            # App launcher icon + display in Home/About
│   └── .gitkeep
│
├── fonts/
│   └── .gitkeep                # Google Fonts downloaded at runtime
│
└── screenshots/                # README images
    ├── 1_home.png
    ├── 2_drawer.png
    ├── 3_player.png
    ├── 4_alphabet.png
    ├── 5_mini_player.png
    └── app_demo.webp
```

## Audio Assets

### Juz Amma Tracks

- **Path pattern:** `assets/audio/juz_amma/{number}-{name}.mp3`
- **Number:** 3-digit padded (001, 078, 079, ..., 114)
- **Name:** English surah name in lowercase (al-fatihah, an-naba, ...)
- **Code reference:** `JuzAmmaData.tracks` computes paths dynamically
- **Sample:** `assets/audio/juz_amma/078-an-naba.mp3`

### Arabic Alphabet Tracks

- **Path pattern:** `assets/audio/arabic_alphabet/{number}-{name}.mp3`
- **Number:** 3-digit padded (001-028)
- **Name:** English letter name in lowercase (alif, baa, ...)
- **Code reference:** `ArabicLetter.assetPath` contains full path
- **Sample:** `assets/audio/arabic_alphabet/005-jeem.mp3`

### Audio Technical Specs

| Property | Surah Tracks | Ayah Tracks | Alphabet Tracks |
| :--- | :--- | :--- | :--- |
| Format | MP3 | MP3 | MP3 |
| Bitrate | ~64 kbps | ~64 kbps | ~64 kbps |
| Channels | Mono | Mono | Mono |
| Total tracks | 38 | 585 (33 surahs) | 28 |
| Total size | ~49 MB | ~170 MB | ~3 MB |

### Ayah Tracks (Hifz Mode)

- **Path pattern:** `assets/audio/juz_amma_ayahs/surah_{NNN}/{NNN}.mp3`
- **Surah numbers:** 078–114 (Juz Amma, 33 surahs; Al-Fatihah not available at ayah level)
- **Index convention:** audio[1] = basmala, audio[2] = verse 1, ... audio[N] = verse N-1
- **Code reference:** `AyahTrackSource.getAyahTracks(surahNumber)` generates all `AudioTrack` objects
- **Mapping:** `ayahFileToVerseNumber()` converts audio index to canonical verse number
- **Registration in pubspec.yaml:**
  ```yaml
  flutter:
    assets:
      - assets/audio/juz_amma_ayahs/
  ```

## Image Assets

| File | Used In |
| :--- | :--- |
| `assets/images/app_icon.png` | HomeScreen (SliverAppBar + Drawer), AboutScreen, App icon |

## Font Assets

Fonts are **not bundled** — they are loaded at runtime via `google_fonts`:

| Font | Usage | Package |
| :--- | :--- | :--- |
| **Amiri** | Arabic display text (surah names, large Arabic text) | `google_fonts` |
| **Cairo** | UI text (labels, titles, body) | `google_fonts` |

See `lib/core/theme/app_typography.dart` for the complete `TextTheme`.

## Asset Registration

Assets are declared in `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/audio/juz_amma/
    - assets/audio/juz_amma_ayahs/
    - assets/audio/arabic_alphabet/
    - assets/images/
```

**Important:** When adding new audio files, ensure they are in the declared directories (subdirectories are auto-included when using trailing `/`).

## Localization

- **Languages:** Arabic (primary), English
- **Implementation:** `flutter_localizations` with `GlobalMaterialLocalizations`
- **Locale delegates:** `GlobalMaterialLocalizations.delegate`, `GlobalWidgetsLocalizations.delegate`, `GlobalCupertinoLocalizations.delegate`
- **Supported locales:** `Locale('en')`, `Locale('ar')`
- **Note:** There are no custom ARB/JSON translation files. The app relies on Flutter's built-in translations and hardcoded Arabic strings in the UI.
- **Direction:** Force-set to RTL in `app.dart`:

```dart
Directionality(textDirection: TextDirection.rtl, child: child)
```
