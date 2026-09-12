import 'package:quran/quran.dart' as quran;

/// Maps a 1‑based audio file index to the canonical Quran verse number.
///
/// **Default rule (per‑surah)**
/// ─────────────────────────────
///  audio[1] → position 0 → **basmala**  (return 0)
///  audio[2] → position 1 →  verse 1
///  audio[3] → position 2 →  verse 2
///  …
///  audio[N] → position N‑1 (capped at [1, verseCount]).
///
/// If the result is less than 1 → `0` (basmala).
/// If it exceeds the surah's canonical verse count → clamp to the last verse.
///
/// **TODO: verify against actual audio content for surahs where**
/// `ayahFileCount != verseCount + 1`.
int ayahFileToVerseNumber(int surahNumber, int audioIndex) {
  if (surahNumber < 1 || surahNumber > 114) return 0;
  final verseCount = quran.getVerseCount(surahNumber);

  // In Surah Al-Fatihah (surah 1), verse 1 IS the Basmala!
  // Audio files 001.mp3 - 007.mp3 map directly to canonical verses 1 - 7:
  if (surahNumber == 1) {
    if (audioIndex < 1) return 1;
    if (audioIndex > verseCount) return verseCount;
    return audioIndex;
  }

  final raw = audioIndex - 1; // offset for basmala

  if (raw < 1) return 0; // basmala
  if (raw > verseCount) return verseCount; // clamp to last verse

  return raw;
}
