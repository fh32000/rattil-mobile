import 'package:quran/quran.dart' as quran;
import '../../../data/sources/ayah_file_to_verse.dart';

/// Lightweight service that wraps the `quran` package with caching.
///
/// Only fetches text when a (surah, verse) pair is first requested;
/// subsequent lookups return instantly from the in‑memory cache.
class VerseService {
  VerseService._();

  static final VerseService _instance = VerseService._();
  factory VerseService() => _instance;

  final Map<String, String> _cache = {};

  String _key(int surah, int verse) => '$surah:$verse';

  /// Returns the Arabic verse text for [surahNumber]:[verseNumber].
  ///
  /// When [verseNumber] is `0` the basmala string is returned.
  String getVerseText(int surahNumber, int verseNumber) {
    if (verseNumber < 1) return quran.basmala;

    final key = _key(surahNumber, verseNumber);
    return _cache.putIfAbsent(
      key,
      () => quran.getVerse(surahNumber, verseNumber, verseEndSymbol: true),
    );
  }

  /// Convenience: resolve audio file index → verse text in one call.
  String getTextForAudioIndex(int surahNumber, int audioIndex) {
    final v = ayahFileToVerseNumber(surahNumber, audioIndex);
    return getVerseText(surahNumber, v);
  }

  /// Returns the verse number for a given audio file index.
  int getVerseForAudioIndex(int surahNumber, int audioIndex) {
    return ayahFileToVerseNumber(surahNumber, audioIndex);
  }

  /// Pre‑fetch a range of verses so they are instantly available later.
  void prefetchRange(int surahNumber, int fromVerse, int toVerse) {
    for (int v = fromVerse; v <= toVerse; v++) {
      getVerseText(surahNumber, v);
    }
  }

  void clearCache() => _cache.clear();
}
