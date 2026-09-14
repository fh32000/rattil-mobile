import 'package:quran/quran.dart' as quran;
import 'ayah_track_source.dart';

/// Maps a 1‑based audio file index to the canonical Quran verse number.
///
/// If [AyahTrackSource] has segments for [surahNumber], it resolves
/// directly from the segment's canonical [verseNumber].
///
/// **Default rule (per‑surah)**
/// ─────────────────────────────
///  audio[1] → position 0 → **basmala**  (return 0)
///  audio[2] → position 1 →  verse 1
///  audio[3] → position 2 →  verse 2
///  …
///  audio[N] → position N‑1 (capped at [1, verseCount]).
int ayahFileToVerseNumber(int surahNumber, int audioIndex) {
  if (surahNumber < 1 || surahNumber > 114) return 0;

  // Use registered/parsed segments if available
  final segments = AyahTrackSource.getSegments(surahNumber);
  if (audioIndex >= 1 && audioIndex <= segments.length) {
    return segments[audioIndex - 1].verseNumber;
  }

  final verseCount = quran.getVerseCount(surahNumber);

  // In Surah Al-Fatihah (surah 1), verse 1 IS the Basmala!
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
