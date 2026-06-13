import 'package:flutter/services.dart' show rootBundle;
import '../models/audio_track.dart';
import '../../core/constants/app_constants.dart';
import 'juz_amma_data.dart';

/// Source of ayah-level audio tracks for Memorization (Hifz) Mode.
///
/// ### Validation
///
/// Validation is lazy and per-surah.  When [hasAyahAudio] is called for a
/// surah that hasn't been validated yet, it returns `true` optimistically
/// (the surah is in [ayahFileCounts]) and kicks off a background validation.
/// Once the background check completes, the cached result is used for
/// subsequent calls.
///
/// This eliminates the 70-call startup bottleneck that was causing ANRs on
/// low-end devices.
class AyahTrackSource {
  AyahTrackSource._();

  static const String _basePath = 'assets/audio/juz_amma_ayahs';

  /// Actual number of ayah audio files per surah
  static const Map<int, int> ayahFileCounts = {
    80: 43,
    81: 30,
    82: 20,
    83: 39,
    84: 27,
    85: 22,
    86: 18,
    87: 21,
    88: 27,
    89: 32,
    90: 23,
    91: 17,
    92: 22,
    93: 12,
    94: 9,
    95: 10,
    96: 20,
    97: 7,
    98: 9,
    99: 9,
    100: 12,
    101: 12,
    102: 9,
    103: 4,
    104: 10,
    105: 6,
    106: 5,
    107: 8,
    108: 4,
    109: 7,
    110: 4,
    111: 6,
    112: 5,
    113: 6,
    114: 7,
  };

  /// Surahs whose audio files have been verified at runtime.
  /// `true` = validated & OK, `false` = validated & FAILED.
  static final Map<int, bool> _validationCache = {};

  /// Whether a background validation is in-flight for a surah.
  static final Set<int> _validating = {};

  /// Whether Memorization Mode is available for [surahNumber].
  ///
  /// Synchronous check: returns the cached validation result if available,
  /// otherwise returns `true` optimistically (surah is in [ayahFileCounts])
  /// and triggers a background validation.
  static bool hasAyahAudio(int surahNumber) {
    if (!ayahFileCounts.containsKey(surahNumber)) return false;

    // Already validated?
    if (_validationCache.containsKey(surahNumber)) {
      return _validationCache[surahNumber]!;
    }

    // Not yet validated — trigger background check, return true optimistically
    _validateSurahInBackground(surahNumber);
    return true;
  }

  /// Validates a single surah in the background (fire-and-forget).
  static void _validateSurahInBackground(int surahNumber) {
    if (_validating.contains(surahNumber)) return;
    _validating.add(surahNumber);

    () async {
      final count = ayahFileCounts[surahNumber]!;
      final first = ayahAssetPath(surahNumber, 1);
      final last = ayahAssetPath(surahNumber, count);

      try {
        await rootBundle.load(first);
        await rootBundle.load(last);
        _validationCache[surahNumber] = true;
        // ignore: avoid_print
        print('[AyahTrackSource] Surah $surahNumber validated ($count files)');
      } catch (_) {
        _validationCache[surahNumber] = false;
        // ignore: avoid_print
        print(
          '[AyahTrackSource] Surah $surahNumber SKIPPED — '
          'file(s) not bundled',
        );
      } finally {
        _validating.remove(surahNumber);
      }
    }();
  }

  static int getAyahCount(int surahNumber) {
    return ayahFileCounts[surahNumber] ?? 0;
  }

  static String ayahAssetPath(int surahNumber, int ayahNumber) {
    final surahPadded = surahNumber.toString().padLeft(3, '0');
    final ayahPadded = ayahNumber.toString().padLeft(3, '0');
    return '$_basePath/surah_$surahPadded/$ayahPadded.mp3';
  }

  static List<AudioTrack> getAyahTracks(int surahNumber) {
    final surah = JuzAmmaData.getSurahByNumber(surahNumber);
    if (surah == null) return [];

    final count = getAyahCount(surahNumber);
    if (count == 0) return [];

    final tracks = <AudioTrack>[];
    for (int i = 1; i <= count; i++) {
      tracks.add(AudioTrack(
        id: '${surahNumber}_ayah_${i.toString().padLeft(3, '0')}',
        surahNumber: surahNumber,
        surahNameArabic: surah.nameArabic,
        surahNameEnglish: surah.nameEnglish,
        reciterName: AppConstants.reciterName,
        assetPath: ayahAssetPath(surahNumber, i),
        pageNumber: surah.pageStart,
        trackType: 'ayah',
        ayahNumber: i,
      ));
    }
    return tracks;
  }
}
