import '../models/surah.dart';
import '../models/audio_track.dart';
import '../sources/juz_amma_data.dart';

/// Repository providing access to Quran data
class QuranRepository {
  /// Get all surahs in Juz Amma
  List<Surah> getAllSurahs() => JuzAmmaData.surahs;

  /// Get all audio tracks
  List<AudioTrack> getAllTracks() => JuzAmmaData.tracks;

  /// Get a surah by number
  Surah? getSurahByNumber(int number) => JuzAmmaData.getSurahByNumber(number);

  /// Get an audio track by surah number
  AudioTrack? getTrackBySurahNumber(int number) =>
      JuzAmmaData.getTrackBySurahNumber(number);

  /// Search surahs by name (Arabic or English)
  List<Surah> searchSurahs(String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return getAllSurahs();
    return JuzAmmaData.surahs.where((surah) {
      return surah.nameArabic.contains(q) ||
          surah.nameEnglish.toLowerCase().contains(q);
    }).toList();
  }

  /// Get surahs by page number
  List<Surah> getSurahsByPage(int page) {
    return JuzAmmaData.surahs.where((s) => s.pageStart == page).toList();
  }

  /// Get tracks by list of track IDs
  List<AudioTrack> getTracksByIds(List<String> ids) {
    final allTracks = JuzAmmaData.tracks;
    return ids
        .map((id) {
          try {
            return allTracks.firstWhere((t) => t.id == id);
          } catch (_) {
            return null;
          }
        })
        .where((t) => t != null)
        .cast<AudioTrack>()
        .toList();
  }
}
