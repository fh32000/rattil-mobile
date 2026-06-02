# 02 Architecture

Warattilhu uses a **Feature-First Architecture** — each feature is a self-contained module with its own UI, providers, and logic. Cross-cutting concerns live in `lib/core/` and `lib/data/`.

## Layer Diagram

```
┌─────────────────────────────────────────────────────┐
│                   UI Layer                           │
│  Screens + Widgets (ConsumerWidget / StatefulWidget) │
│  lib/features/<feature>/screens/                     │
│  lib/features/<feature>/widgets/                     │
└────────────────┬────────────────────────────────────┘
                 │ ref.watch(provider)
                 ▼
┌─────────────────────────────────────────────────────┐
│               State Layer (Riverpod)                 │
│  StreamProvider / StateNotifierProvider / Provider    │
│  lib/features/player/providers/audio_provider.dart   │
│  lib/features/updates/providers/update_provider.dart │
└────────────────┬────────────────────────────────────┘
                 │ calls methods on
                 ▼
┌─────────────────────────────────────────────────────┐
│            Business Logic Layer                       │
│  Services / Repositories / Handlers                   │
│  lib/features/player/services/audio_handler.dart     │
│  lib/core/services/update_service.dart               │
└────────────────┬────────────────────────────────────┘
                 │ reads/writes
                 ▼
┌─────────────────────────────────────────────────────┐
│               Data Layer                              │
│  Models + Data Sources + Hive Boxes                   │
│  lib/data/models/*.dart                               │
│  lib/data/sources/*.dart                              │
│  lib/data/repositories/*.dart                         │
└────────────────┬────────────────────────────────────┘
                 │ persists/reads
                 ▼
┌─────────────────────────────────────────────────────┐
│              Storage Layer                            │
│  Hive (local NoSQL) + Asset MP3 files                 │
│  lib/data/hive/hive_service.dart                      │
│  assets/audio/juz_amma/                               │
│  assets/audio/arabic_alphabet/                        │
└─────────────────────────────────────────────────────┘
```

## How Layers Communicate

1. **UI → Provider:** Widget calls `ref.watch(provider)` or `ref.read(provider.notifier).method()`
2. **Provider → Service:** Provider holds instance of service/repository and delegates calls
3. **Service → Data:** Service reads/writes via repositories or directly to data sources
4. **Data → Storage:** Repositories persist to Hive boxes or read from static data sources
5. **State → UI:** Provider emits new state → UI rebuilds via Riverpod's reactive system

## Key Architectural Decisions

| Decision | Rationale |
| :--- | :--- |
| Single `QuranAudioHandler` | Global singleton initialized in `main()`; shared across all screens via Provider. Also manages Hifz memorization mode with ayah-level playback, repetition, and pause timing |
| Hifz as a mode, not a screen | Turns player into ayah-level memorization tool; saves/restores track list on toggle |
| Hive for storage | Fast local NoSQL without SQLite overhead; no need for complex queries |
| Static data sources | Juz Amma and alphabet data are compile-time constants; no API needed |
| StreamProviders for audio | Audio player emits continuous position/state streams; natural fit |
| `SliverAppBar` + `CustomScrollView` | Smooth scrolling with pinned headers for all list-based screens |
| `MiniPlayer` in `Stack` | Positioned fixed at bottom of every screen that shows list content |

## Feature Independence

Each feature in `lib/features/` is self-contained:

```
feature/
├── screens/
├── widgets/  (optional)
├── providers/ (optional)
└── services/ (optional)
```

Features can import from `core/`, `data/`, and other features' providers (e.g., `home/` imports `player/providers/audio_provider.dart`).
