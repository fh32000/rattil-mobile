import '../models/surah.dart';
import '../models/audio_track.dart';

/// بيانات جزء عمّ - سور 78 إلى 114
class JuzAmmaData {
  JuzAmmaData._();

  static const List<Surah> surahs = [
    Surah(number: 78, nameArabic: 'النبأ', nameEnglish: 'An-Naba', versesCount: 40, pageStart: 582, revelationType: 'مكية'),
    Surah(number: 79, nameArabic: 'النازعات', nameEnglish: 'An-Naziat', versesCount: 46, pageStart: 583, revelationType: 'مكية'),
    Surah(number: 80, nameArabic: 'عبس', nameEnglish: 'Abasa', versesCount: 42, pageStart: 585, revelationType: 'مكية'),
    Surah(number: 81, nameArabic: 'التكوير', nameEnglish: 'At-Takwir', versesCount: 29, pageStart: 586, revelationType: 'مكية'),
    Surah(number: 82, nameArabic: 'الانفطار', nameEnglish: 'Al-Infitar', versesCount: 19, pageStart: 587, revelationType: 'مكية'),
    Surah(number: 83, nameArabic: 'المطففين', nameEnglish: 'Al-Mutaffifin', versesCount: 36, pageStart: 587, revelationType: 'مكية'),
    Surah(number: 84, nameArabic: 'الانشقاق', nameEnglish: 'Al-Inshiqaq', versesCount: 25, pageStart: 589, revelationType: 'مكية'),
    Surah(number: 85, nameArabic: 'البروج', nameEnglish: 'Al-Buruj', versesCount: 22, pageStart: 590, revelationType: 'مكية'),
    Surah(number: 86, nameArabic: 'الطارق', nameEnglish: 'At-Tariq', versesCount: 17, pageStart: 591, revelationType: 'مكية'),
    Surah(number: 87, nameArabic: 'الأعلى', nameEnglish: 'Al-Ala', versesCount: 19, pageStart: 591, revelationType: 'مكية'),
    Surah(number: 88, nameArabic: 'الغاشية', nameEnglish: 'Al-Ghashiyah', versesCount: 26, pageStart: 592, revelationType: 'مكية'),
    Surah(number: 89, nameArabic: 'الفجر', nameEnglish: 'Al-Fajr', versesCount: 30, pageStart: 593, revelationType: 'مكية'),
    Surah(number: 90, nameArabic: 'البلد', nameEnglish: 'Al-Balad', versesCount: 20, pageStart: 594, revelationType: 'مكية'),
    Surah(number: 91, nameArabic: 'الشمس', nameEnglish: 'Ash-Shams', versesCount: 15, pageStart: 595, revelationType: 'مكية'),
    Surah(number: 92, nameArabic: 'الليل', nameEnglish: 'Al-Lail', versesCount: 21, pageStart: 595, revelationType: 'مكية'),
    Surah(number: 93, nameArabic: 'الضحى', nameEnglish: 'Ad-Duha', versesCount: 11, pageStart: 596, revelationType: 'مكية'),
    Surah(number: 94, nameArabic: 'الشرح', nameEnglish: 'Ash-Sharh', versesCount: 8, pageStart: 596, revelationType: 'مكية'),
    Surah(number: 95, nameArabic: 'التين', nameEnglish: 'At-Tin', versesCount: 8, pageStart: 597, revelationType: 'مكية'),
    Surah(number: 96, nameArabic: 'العلق', nameEnglish: 'Al-Alaq', versesCount: 19, pageStart: 597, revelationType: 'مكية'),
    Surah(number: 97, nameArabic: 'القدر', nameEnglish: 'Al-Qadr', versesCount: 5, pageStart: 598, revelationType: 'مكية'),
    Surah(number: 98, nameArabic: 'البينة', nameEnglish: 'Al-Bayyinah', versesCount: 8, pageStart: 598, revelationType: 'مدنية'),
    Surah(number: 99, nameArabic: 'الزلزلة', nameEnglish: 'Az-Zalzalah', versesCount: 8, pageStart: 599, revelationType: 'مدنية'),
    Surah(number: 100, nameArabic: 'العاديات', nameEnglish: 'Al-Adiyat', versesCount: 11, pageStart: 599, revelationType: 'مكية'),
    Surah(number: 101, nameArabic: 'القارعة', nameEnglish: 'Al-Qariah', versesCount: 11, pageStart: 600, revelationType: 'مكية'),
    Surah(number: 102, nameArabic: 'التكاثر', nameEnglish: 'At-Takathur', versesCount: 8, pageStart: 600, revelationType: 'مكية'),
    Surah(number: 103, nameArabic: 'العصر', nameEnglish: 'Al-Asr', versesCount: 3, pageStart: 601, revelationType: 'مكية'),
    Surah(number: 104, nameArabic: 'الهمزة', nameEnglish: 'Al-Humazah', versesCount: 9, pageStart: 601, revelationType: 'مكية'),
    Surah(number: 105, nameArabic: 'الفيل', nameEnglish: 'Al-Fil', versesCount: 5, pageStart: 601, revelationType: 'مكية'),
    Surah(number: 106, nameArabic: 'قريش', nameEnglish: 'Quraysh', versesCount: 4, pageStart: 602, revelationType: 'مكية'),
    Surah(number: 107, nameArabic: 'الماعون', nameEnglish: 'Al-Maun', versesCount: 7, pageStart: 602, revelationType: 'مكية'),
    Surah(number: 108, nameArabic: 'الكوثر', nameEnglish: 'Al-Kawthar', versesCount: 3, pageStart: 602, revelationType: 'مكية'),
    Surah(number: 109, nameArabic: 'الكافرون', nameEnglish: 'Al-Kafirun', versesCount: 6, pageStart: 603, revelationType: 'مكية'),
    Surah(number: 110, nameArabic: 'النصر', nameEnglish: 'An-Nasr', versesCount: 3, pageStart: 603, revelationType: 'مدنية'),
    Surah(number: 111, nameArabic: 'المسد', nameEnglish: 'Al-Masad', versesCount: 5, pageStart: 603, revelationType: 'مكية'),
    Surah(number: 112, nameArabic: 'الإخلاص', nameEnglish: 'Al-Ikhlas', versesCount: 4, pageStart: 604, revelationType: 'مكية'),
    Surah(number: 113, nameArabic: 'الفلق', nameEnglish: 'Al-Falaq', versesCount: 5, pageStart: 604, revelationType: 'مكية'),
    Surah(number: 114, nameArabic: 'الناس', nameEnglish: 'An-Nas', versesCount: 6, pageStart: 604, revelationType: 'مدنية'),
  ];

  static List<AudioTrack> get tracks {
    return surahs.map((surah) {
      final paddedNumber = surah.number.toString().padLeft(3, '0');
      return AudioTrack(
        id: 'juz_amma_$paddedNumber',
        surahNumber: surah.number,
        surahNameArabic: surah.nameArabic,
        surahNameEnglish: surah.nameEnglish,
        reciterName: 'أحمد عمر الخامر',
        assetPath: 'assets/audio/juz_amma/$paddedNumber-${surah.nameEnglish.toLowerCase()}.mp3',
        pageNumber: surah.pageStart,
      );
    }).toList();
  }

  static Surah? getSurahByNumber(int number) {
    try {
      return surahs.firstWhere((s) => s.number == number);
    } catch (_) {
      return null;
    }
  }

  static AudioTrack? getTrackBySurahNumber(int number) {
    final paddedNumber = number.toString().padLeft(3, '0');
    try {
      return tracks.firstWhere((t) => t.id == 'juz_amma_$paddedNumber');
    } catch (_) {
      return null;
    }
  }
}
