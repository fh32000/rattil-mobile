## 1.0.18

- Full audio standardization across all 37 surahs of Juz Amma (Surahs 78 to 114)
- 100% canonical ayah alignment: every clip precisely matches its canonical Quran verse number
- Unified Basmala architecture: `000.mp3` for Basmala (verse 0) across all surahs, preserving Al-Fatiha (`001.mp3`)
- Comprehensive multi-part ayah support: seamless playback and repetition for split ayahs (`-1.mp3`, `-2.mp3`) in Surahs 78, 83, 84, 87, 89, 90, 95, 97
- High-precision audio splitting: separated merged ayahs at exact silence boundaries using ffmpeg (Surahs 79 and 85)
- Hifz mode repetition fixes: non-repeating Basmala in all surahs except Al-Fatiha, and resolved playback stalls in the listening phase
- Reciter screen enhancement: added reciter center info card
- Automated validation suite: 38 passing unit and integration tests covering all 37 surahs of Juz Amma

## 1.0.16

- Playlist UX overhaul: multi-select add/remove, reorderable tracks, sort by surah number, play-from-item
- Global playback speed control with persistent speed setting (0.5x - 2.0x)
- Playlist playback fix: corrected type casting bug that prevented playlist audio from playing
- New app icon: updated Warattil calligraphy design
- Mini player improvements: speed indicator, playlist name display, letter index display
- Letter playback: auto-continue when navigating Next/Previous letters
- Playlist FAB: proper safe area spacing for Android navigation bar
- Scroll padding fix across all screens for mini player clearance

## 1.0.0

- Initial version.
