import '../models/arabic_letter.dart';
import '../models/audio_track.dart';

class ArabicAlphabetData {
  ArabicAlphabetData._();

  /// Convert all letters to AudioTrack list for playlist playback
  static List<AudioTrack> toAudioTracks() {
    return letters
        .map(
          (l) => AudioTrack(
            id: 'letter_${l.number}',
            surahNumber: 0,
            surahNameArabic: l.name,
            surahNameEnglish: l.nameEnglish,
            reciterName: 'مخارج الحروف',
            assetPath: l.assetPath,
            pageNumber: 0,
            trackType: 'alphabet',
          ),
        )
        .toList();
  }

  static const List<ArabicLetter> letters = [
    ArabicLetter(
      number: 1,
      arabicLetter: 'أ',
      name: 'الألف',
      nameEnglish: 'alif',
      makhrajGroup: 'الحلق',
      makhrajDetail: 'أقصى الحلق',
      assetPath: 'assets/audio/arabic_alphabet/001-alif.mp3',
    ),
    ArabicLetter(
      number: 2,
      arabicLetter: 'ب',
      name: 'الباء',
      nameEnglish: 'baa',
      makhrajGroup: 'الشفتان',
      makhrajDetail: 'انطباق الشفتين',
      assetPath: 'assets/audio/arabic_alphabet/002-baa.mp3',
    ),
    ArabicLetter(
      number: 3,
      arabicLetter: 'ت',
      name: 'التاء',
      nameEnglish: 'taa',
      makhrajGroup: 'اللسان',
      makhrajDetail: 'طرف اللسان مع أصول الثنايا العليا',
      assetPath: 'assets/audio/arabic_alphabet/003-taa.mp3',
    ),
    ArabicLetter(
      number: 4,
      arabicLetter: 'ث',
      name: 'الثاء',
      nameEnglish: 'thaa',
      makhrajGroup: 'اللسان',
      makhrajDetail: 'طرف اللسان مع أطراف الثنايا العليا',
      assetPath: 'assets/audio/arabic_alphabet/004-thaa.mp3',
    ),
    ArabicLetter(
      number: 5,
      arabicLetter: 'ج',
      name: 'الجيم',
      nameEnglish: 'jeem',
      makhrajGroup: 'اللسان',
      makhrajDetail: 'وسط اللسان مع وسط الحنك الأعلى',
      assetPath: 'assets/audio/arabic_alphabet/005-jeem.mp3',
    ),
    ArabicLetter(
      number: 6,
      arabicLetter: 'ح',
      name: 'الحاء',
      nameEnglish: 'haa',
      makhrajGroup: 'الحلق',
      makhrajDetail: 'وسط الحلق',
      assetPath: 'assets/audio/arabic_alphabet/006-haa.mp3',
    ),
    ArabicLetter(
      number: 7,
      arabicLetter: 'خ',
      name: 'الخاء',
      nameEnglish: 'khaa',
      makhrajGroup: 'الحلق',
      makhrajDetail: 'أدنى الحلق',
      assetPath: 'assets/audio/arabic_alphabet/007-khaa.mp3',
    ),
    ArabicLetter(
      number: 8,
      arabicLetter: 'د',
      name: 'الدال',
      nameEnglish: 'daal',
      makhrajGroup: 'اللسان',
      makhrajDetail: 'طرف اللسان مع أصول الثنايا العليا',
      assetPath: 'assets/audio/arabic_alphabet/008-daal.mp3',
    ),
    ArabicLetter(
      number: 9,
      arabicLetter: 'ذ',
      name: 'الذال',
      nameEnglish: 'thaal',
      makhrajGroup: 'اللسان',
      makhrajDetail: 'طرف اللسان مع أطراف الثنايا العليا',
      assetPath: 'assets/audio/arabic_alphabet/009-thaal.mp3',
    ),
    ArabicLetter(
      number: 10,
      arabicLetter: 'ر',
      name: 'الراء',
      nameEnglish: 'raa',
      makhrajGroup: 'اللسان',
      makhrajDetail: 'طرف اللسان مع ما يحاذيه من اللثة العليا',
      assetPath: 'assets/audio/arabic_alphabet/010-raa.mp3',
    ),
    ArabicLetter(
      number: 11,
      arabicLetter: 'ز',
      name: 'الزاي',
      nameEnglish: 'zay',
      makhrajGroup: 'اللسان',
      makhrajDetail: 'طرف اللسان مع ما يحاذيه من الثنايا السفلى',
      assetPath: 'assets/audio/arabic_alphabet/011-zay.mp3',
    ),
    ArabicLetter(
      number: 12,
      arabicLetter: 'س',
      name: 'السين',
      nameEnglish: 'seen',
      makhrajGroup: 'اللسان',
      makhrajDetail: 'طرف اللسان مع الثنايا السفلى',
      assetPath: 'assets/audio/arabic_alphabet/012-seen.mp3',
    ),
    ArabicLetter(
      number: 13,
      arabicLetter: 'ش',
      name: 'الشين',
      nameEnglish: 'sheen',
      makhrajGroup: 'اللسان',
      makhrajDetail: 'وسط اللسان مع وسط الحنك الأعلى',
      assetPath: 'assets/audio/arabic_alphabet/013-sheen.mp3',
    ),
    ArabicLetter(
      number: 14,
      arabicLetter: 'ص',
      name: 'الصاد',
      nameEnglish: 'saad',
      makhrajGroup: 'اللسان',
      makhrajDetail: 'طرف اللسان مع الثنايا السفلى',
      assetPath: 'assets/audio/arabic_alphabet/014-saad.mp3',
    ),
    ArabicLetter(
      number: 15,
      arabicLetter: 'ض',
      name: 'الضاد',
      nameEnglish: 'daad',
      makhrajGroup: 'اللسان',
      makhrajDetail: 'حافة اللسان مع ما يليها من الأضراس العليا',
      assetPath: 'assets/audio/arabic_alphabet/015-daad.mp3',
    ),
    ArabicLetter(
      number: 16,
      arabicLetter: 'ط',
      name: 'الطاء',
      nameEnglish: 'taa_heavy',
      makhrajGroup: 'اللسان',
      makhrajDetail: 'طرف اللسان مع أصول الثنايا العليا',
      assetPath: 'assets/audio/arabic_alphabet/016-taa_heavy.mp3',
    ),
    ArabicLetter(
      number: 17,
      arabicLetter: 'ظ',
      name: 'الظاء',
      nameEnglish: 'dhaa',
      makhrajGroup: 'اللسان',
      makhrajDetail: 'طرف اللسان مع أطراف الثنايا العليا',
      assetPath: 'assets/audio/arabic_alphabet/017-dhaa.mp3',
    ),
    ArabicLetter(
      number: 18,
      arabicLetter: 'ع',
      name: 'العين',
      nameEnglish: 'ayn',
      makhrajGroup: 'الحلق',
      makhrajDetail: 'وسط الحلق',
      assetPath: 'assets/audio/arabic_alphabet/018-ayn.mp3',
    ),
    ArabicLetter(
      number: 19,
      arabicLetter: 'غ',
      name: 'الغين',
      nameEnglish: 'ghayn',
      makhrajGroup: 'الحلق',
      makhrajDetail: 'أدنى الحلق',
      assetPath: 'assets/audio/arabic_alphabet/019-ghayn.mp3',
    ),
    ArabicLetter(
      number: 20,
      arabicLetter: 'ف',
      name: 'الفاء',
      nameEnglish: 'faa',
      makhrajGroup: 'الشفتان',
      makhrajDetail: 'باطن الشفة السفلى مع أطراف الثنايا العليا',
      assetPath: 'assets/audio/arabic_alphabet/020-faa.mp3',
    ),
    ArabicLetter(
      number: 21,
      arabicLetter: 'ق',
      name: 'القاف',
      nameEnglish: 'qaaf',
      makhrajGroup: 'اللسان',
      makhrajDetail: 'أقصى اللسان مع ما يحاذيه من الحنك الأعلى',
      assetPath: 'assets/audio/arabic_alphabet/021-qaaf.mp3',
    ),
    ArabicLetter(
      number: 22,
      arabicLetter: 'ك',
      name: 'الكاف',
      nameEnglish: 'kaaf',
      makhrajGroup: 'اللسان',
      makhrajDetail: 'أقصى اللسان مع ما يحاذيه من الحنك الأعلى',
      assetPath: 'assets/audio/arabic_alphabet/022-kaaf.mp3',
    ),
    ArabicLetter(
      number: 23,
      arabicLetter: 'ل',
      name: 'اللام',
      nameEnglish: 'laam',
      makhrajGroup: 'اللسان',
      makhrajDetail: 'طرف اللسان مع ما يلي الثنايا العليا',
      assetPath: 'assets/audio/arabic_alphabet/023-laam.mp3',
    ),
    ArabicLetter(
      number: 24,
      arabicLetter: 'م',
      name: 'الميم',
      nameEnglish: 'meem',
      makhrajGroup: 'الشفتان',
      makhrajDetail: 'انطباق الشفتين',
      assetPath: 'assets/audio/arabic_alphabet/024-meem.mp3',
    ),
    ArabicLetter(
      number: 25,
      arabicLetter: 'ن',
      name: 'النون',
      nameEnglish: 'noon',
      makhrajGroup: 'اللسان',
      makhrajDetail: 'طرف اللسان مع ما يحاذيه من اللثة العليا',
      assetPath: 'assets/audio/arabic_alphabet/025-noon.mp3',
    ),
    ArabicLetter(
      number: 26,
      arabicLetter: 'ه',
      name: 'الهاء',
      nameEnglish: 'haa_light',
      makhrajGroup: 'الحلق',
      makhrajDetail: 'أقصى الحلق',
      assetPath: 'assets/audio/arabic_alphabet/026-haa_light.mp3',
    ),
    ArabicLetter(
      number: 27,
      arabicLetter: 'و',
      name: 'الواو',
      nameEnglish: 'waw',
      makhrajGroup: 'الشفتان',
      makhrajDetail: 'انضمام الشفتين',
      assetPath: 'assets/audio/arabic_alphabet/027-waw.mp3',
    ),
    ArabicLetter(
      number: 28,
      arabicLetter: 'ي',
      name: 'الياء',
      nameEnglish: 'yaa',
      makhrajGroup: 'اللسان',
      makhrajDetail: 'وسط اللسان مع وسط الحنك الأعلى',
      assetPath: 'assets/audio/arabic_alphabet/028-yaa.mp3',
    ),
  ];

  static const List<String> groups = ['الكل', 'الحلق', 'اللسان', 'الشفتان'];

  static List<ArabicLetter> getByGroup(String group) {
    if (group == 'الكل') return letters;
    return letters.where((l) => l.makhrajGroup == group).toList();
  }

  static ArabicLetter? getByNumber(int number) {
    try {
      return letters.firstWhere((l) => l.number == number);
    } catch (_) {
      return null;
    }
  }
}
