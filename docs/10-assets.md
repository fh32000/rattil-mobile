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

| Property | Value |
| :--- | :--- |
| Format | MP3 |
| Bitrate | ~64 kbps |
| Channels | Mono |
| Total tracks | 66 (38 surahs + 28 letters) |
| Total size | ~49 MB |

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
