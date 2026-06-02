# 01 Project Overview

## What is Warattilhu?

Warattilhu (ورتِّله) is a premium Quran recitation Flutter application. It delivers an immersive audio experience for listening to Juz Amma (Surahs 78-114 + Al-Fatihah) and learning Arabic letter pronunciation (Tajweed / مخارج الحروف).

**Package name:** `rattil`  
**Version:** `1.0.13+1`  
**Tech:** Flutter 3.8+, Dart 3.8+, Firebase Analytics + Crashlytics

## Goal

Provide a seamless, spiritually focused audio journey with:
- High-quality embedded MP3 recitations (64kbps mono, ~49 MB total)
- Background playback with lock-screen controls
- Educational tools for Arabic phonetics
- Offline-first architecture (all audio bundled)

## Target User

Muslims worldwide — Arabic speakers and learners — who want:
- To listen to Quran recitation by Shaykh Omar Ahmed Omar Al-Khamer
- To learn correct Arabic letter articulation (makharij)
- Save favorite surahs and create custom playlists

## Problems Solved

| Problem | Solution |
| :--- | :--- |
| Poor Quran app UX | Modern Material 3 dark UI, smooth animations, RTL |
| No offline audio | All 66 MP3 files bundled (Juz Amma + 28 alphabet letters) |
| No background play | Audio Service + Just Audio for background + lock screen |
| Hard to find letters | Makhraj groups filter (throat, tongue, lips) with audio examples |
| No progress saving | Hive persists position per track every 3 seconds |

## Key Features

| Feature | Details |
| :--- | :--- |
| Quran Audio | 38 surahs (Al-Fatihah + Juz Amma), bundled MP3 |
| Arabic Alphabet | 28 letters with makhraj groups, audio pronunciation |
| Full Player | Play/pause, skip, seek, rewind/forward 10s, loop modes |
| Mini Player | Persistent bottom bar with progress, controls |
| Background Playback | Audio keeps playing when app is minimized |
| Lock Screen Controls | Media notifications on Android/iOS |
| Favorites System | Heart toggle on any track, dedicated favorites screen |
| Playlists | Create/delete custom playlists, add/remove tracks |
| Search | Search by surah name (Arabic/English), number, or page |
| Reciter Bio | Biography of Shaykh Omar Ahmed Omar Al-Khamer |
| Update Checker | Remote version check from woostore.dev |
| Hifz Memorization | Ayah-by-ayah repetition engine with configurable repeat count, recitation pause, verse display, speed/volume controls, and persistent settings |
| Dark Mode | Always-on dark theme with teal/gold palette |
| RTL | Full Arabic right-to-left layout |

## Technical Highlights

- **No network required** for core functionality (audio is bundled)
- **Feature-first architecture** — each feature is self-contained
- **Reactive state** via Riverpod StreamProviders
- **Single audio handler** shared across all screens via Riverpod
