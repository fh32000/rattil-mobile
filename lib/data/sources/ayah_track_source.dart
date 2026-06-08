import 'package:flutter/services.dart' show rootBundle;
import '../models/audio_track.dart';
import '../models/surah.dart';
import '../../core/constants/app_constants.dart';
import 'juz_amma_data.dart';

/// Source of ayah-level audio tracks for Memorization (Hifz) Mode.
///
/// ### Validation
///
/// [init] must be called once at app startup.  It spot-checks the first and
/// last audio file of every surah listed in [ayahFileCounts] to confirm the
/// files are bundled in the APK.  Any surah whose files fail to load is
/// excluded from [hasAyahAudio] — Memorization Mode will not be offered for
/// that surah.
///
/// This design eliminates runtime fallback / recovery logic: an unsupported
/// surah is simply hidden from the user rather than repaired dynamically.
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
  static final Set<int> _validatedSurahs = {};
  static bool _initDone = false;

  /// Must be called once at app startup (e.g. in `AudioService.init` or
  /// the audio-handler constructor).  Spot-checks the first and last ayah
  /// file of each surah; surahs whose assets can't be loaded are excluded.
  static Future<void> init() async {
    if (_initDone) return;
    _initDone = true;

    for (final entry in ayahFileCounts.entries) {
      final surah = entry.key;
      final count = entry.value;

      final first = ayahAssetPath(surah, 1);
      final last = ayahAssetPath(surah, count);

      try {
        await rootBundle.load(first);
        await rootBundle.load(last);
        _validatedSurahs.add(surah);
        // ignore: avoid_print
        print('[AyahTrackSource] Surah $surah validated ($count files)');
      } catch (_) {
        // ignore: avoid_print
        print(
          '[AyahTrackSource] Surah $surah SKIPPED — '
          'file(s) not bundled',
        );
      }
    }
  }

  /// Whether Memorization Mode is available for [surahNumber].
  ///
  /// Returns `true` only when the surah is listed in [ayahFileCounts] AND
  /// [init] has confirmed its audio files are accessible.
  static bool hasAyahAudio(int surahNumber) {
    if (!ayahFileCounts.containsKey(surahNumber)) return false;
    if (!_validatedSurahs.contains(surahNumber)) return false;
    return true;
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
