# 03 Tech Stack

## Flutter

| | |
| :--- | :--- |
| **What** | Cross-platform UI framework by Google |
| **Why** | Single codebase for Android, iOS, Web; excellent RTL/Material 3 support |
| **Where** | Everywhere — the entire app is Flutter/Dart |
| **Alternatives** | React Native, Kotlin Multiplatform, SwiftUI |

## Dart

| | |
| :--- | :--- |
| **What** | Strongly typed, optimized-for-UI language |
| **Why** | Required by Flutter; sound null safety, pattern matching, records |
| **Where** | Every `.dart` file in `lib/` |
| **Alternatives** | Kotlin, Swift, TypeScript |

## Riverpod (`flutter_riverpod`)

| | |
| :--- | :--- |
| **What** | Compile-safe, scalable state management |
| **Why** | No BuildContext dependency, autodispose, StreamProvider fits audio streams |
| **Where** | `lib/features/player/providers/audio_provider.dart` (8 providers + favorites), `lib/features/updates/providers/update_provider.dart` |
| **Alternatives** | Provider, BLoC, GetX, MobX |

**Key providers used:**
- `Provider` — simple dependency injection (e.g., `audioHandlerProvider`)
- `StreamProvider` — audio position, playback state, current track
- `StateNotifierProvider` — favorites set, playlists list, update state

## Go Router (`go_router`)

| | |
| :--- | :--- |
| **What** | Declarative Flutter routing |
| **Why** | Type-safe, supports `pathParameters`, custom page transitions |
| **Where** | `lib/core/router/app_router.dart` — all 12 routes defined in one file |
| **Alternatives** | Navigator 2.0, auto_route, Beamer |

**Routes:**
- `/` — HomeScreen
- `/surah/:surahNumber` — SurahDetailScreen
- `/player` — PlayerScreen (with slide-up transition)
- `/favorites`, `/playlists`, `/search`, `/reciter`, `/about`, `/support`
- `/arabic-alphabet`, `/arabic-alphabet/:number`
- `/updates`

## Just Audio (`just_audio`)

| | |
| :--- | :--- |
| **What** | Production-grade audio playback engine |
| **Why** | Supports local assets, gapless playback, seek, stream position |
| **Where** | `lib/features/player/services/audio_handler.dart` — single `AudioPlayer` instance |
| **Alternatives** | audioplayers, flutter_midi, native platform channels |

## Audio Service (`audio_service`)

| | |
| :--- | :--- |
| **What** | Background audio + OS media integration |
| **Why** | Required for background playback, lock screen controls, Android notification |
| **Where** | `lib/features/player/services/audio_handler.dart` — `QuranAudioHandler extends BaseAudioHandler`; initialized in `lib/features/player/providers/audio_provider.dart` |
| **Alternatives** | flutter_background_service, just_audio_background |

## Audio Session (`audio_session`)

| | |
| :--- | :--- |
| **What** | Configures OS audio session (ducking, focus) |
| **Why** | Ensures audio behaves well with other apps |
| **Where** | Transitive dependency of `audio_service` |

## Hive (`hive_flutter`)

| | |
| :--- | :--- |
| **What** | Lightweight, fast local NoSQL database |
| **Why** | Zero dependency, no native setup, very fast reads/writes for small data |
| **Where** | `lib/data/hive/hive_service.dart` — 4 boxes: `playback_positions`, `favorites`, `playlists`, `settings` |
| **Alternatives** | sqflite, shared_preferences, drift, ObjectBox |

## Other Dependencies

| Package | Purpose |
| :--- | :--- |
| `rxdart` | CombineLatest for joining track list + index streams |
| `url_launcher` | Open WhatsApp, email, phone from About/Support screens |
| `google_fonts` | Amiri (Arabic display) + Cairo (UI text) fonts |
| `http` | Fetch version.json for update checking |
| `package_info_plus` | Get current app version for update comparison |
| `flutter_localizations` + `intl` | Arabic + English locale support |
