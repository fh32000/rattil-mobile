import '../models/audio_track.dart';
import '../models/surah.dart';
import '../../core/constants/app_constants.dart';
import 'juz_amma_data.dart';

class AyahTrackSource {
  AyahTrackSource._();

  static const String _basePath = 'assets/audio/juz_amma_ayahs';

  /// Actual number of ayah audio files per surah
  static const Map<int, int> ayahFileCounts = {
    78: 44,
    79: 46,
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

  static bool hasAyahAudio(int surahNumber) {
    return ayahFileCounts.containsKey(surahNumber);
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
