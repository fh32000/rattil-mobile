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
            surahNumber: l.number,
            surahNameArabic: l.name,
            surahNameEnglish: l.nameEnglish,
            reciterName: 'مخارج الحروف',
            assetPath: l.nameAssetPath,
            pageNumber: 0,
            trackType: 'alphabet',
            segmentKind: 'name',
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
    ),
    ArabicLetter(
      number: 2,
      arabicLetter: 'ب',
      name: 'الباء',
      nameEnglish: 'baa',
      makhrajGroup: 'الشفتان',
      makhrajDetail: 'انطباق الشفتين',
    ),
    ArabicLetter(
      number: 3,
      arabicLetter: 'ت',
      name: 'التاء',
      nameEnglish: 'taa',
      makhrajGroup: 'اللسان',
      makhrajDetail: 'طرف اللسان مع أصول الثنايا العليا',
    ),
    ArabicLetter(
      number: 4,
      arabicLetter: 'ث',
      name: 'الثاء',
      nameEnglish: 'thaa',
      makhrajGroup: 'اللسان',
      makhrajDetail: 'طرف اللسان مع أطراف الثنايا العليا',
    ),
    ArabicLetter(
      number: 5,
      arabicLetter: 'ج',
      name: 'الجيم',
      nameEnglish: 'jeem',
      makhrajGroup: 'اللسان',
      makhrajDetail: 'وسط اللسان مع وسط الحنك الأعلى',
    ),
    ArabicLetter(
      number: 6,
      arabicLetter: 'ح',
      name: 'الحاء',
      nameEnglish: 'haa',
      makhrajGroup: 'الحلق',
      makhrajDetail: 'وسط الحلق',
    ),
    ArabicLetter(
      number: 7,
      arabicLetter: 'خ',
      name: 'الخاء',
      nameEnglish: 'khaa',
      makhrajGroup: 'الحلق',
      makhrajDetail: 'أدنى الحلق',
    ),
    ArabicLetter(
      number: 8,
      arabicLetter: 'د',
      name: 'الدال',
      nameEnglish: 'daal',
      makhrajGroup: 'اللسان',
      makhrajDetail: 'طرف اللسان مع أصول الثنايا العليا',
    ),
    ArabicLetter(
      number: 9,
      arabicLetter: 'ذ',
      name: 'الذال',
      nameEnglish: 'thaal',
      makhrajGroup: 'اللسان',
      makhrajDetail: 'طرف اللسان مع أطراف الثنايا العليا',
    ),
    ArabicLetter(
      number: 10,
      arabicLetter: 'ر',
      name: 'الراء',
      nameEnglish: 'raa',
      makhrajGroup: 'اللسان',
      makhrajDetail: 'طرف اللسان مائلاً إلى ظهره قليلاً مع لثة الثنايا العليا',
    ),
    ArabicLetter(
      number: 11,
      arabicLetter: 'ز',
      name: 'الزاي',
      nameEnglish: 'zay',
      makhrajGroup: 'اللسان',
      makhrajDetail: 'رأس طرف اللسان مع ما بين الثنايا العليا والسفلى',
    ),
    ArabicLetter(
      number: 12,
      arabicLetter: 'س',
      name: 'السين',
      nameEnglish: 'seen',
      makhrajGroup: 'اللسان',
      makhrajDetail: 'رأس طرف اللسان مع ما بين الثنايا العليا والسفلى',
    ),
    ArabicLetter(
      number: 13,
      arabicLetter: 'ش',
      name: 'الشين',
      nameEnglish: 'sheen',
      makhrajGroup: 'اللسان',
      makhrajDetail: 'وسط اللسان مع ما يحاذيه من الحنك الأعلى',
    ),
    ArabicLetter(
      number: 14,
      arabicLetter: 'ص',
      name: 'الصاد',
      nameEnglish: 'saad',
      makhrajGroup: 'اللسان',
      makhrajDetail: 'رأس طرف اللسان مع ما بين الثنايا العليا والسفلى مع الاستعلاء',
    ),
    ArabicLetter(
      number: 15,
      arabicLetter: 'ض',
      name: 'الضاد',
      nameEnglish: 'daad',
      makhrajGroup: 'اللسان',
      makhrajDetail: 'إحدى حافتي اللسان أو كلاهما مع ما يحاذيها من الأضراس العليا',
    ),
    ArabicLetter(
      number: 16,
      arabicLetter: 'ط',
      name: 'الطاء',
      nameEnglish: 'taa_heavy',
      makhrajGroup: 'اللسان',
      makhrajDetail: 'طرف اللسان مع أصول الثنايا العليا مع الإطباق',
    ),
    ArabicLetter(
      number: 17,
      arabicLetter: 'ظ',
      name: 'الظاء',
      nameEnglish: 'dhaa',
      makhrajGroup: 'اللسان',
      makhrajDetail: 'طرف اللسان مع أطراف الثنايا العليا مع الإطباق',
    ),
    ArabicLetter(
      number: 18,
      arabicLetter: 'ع',
      name: 'العين',
      nameEnglish: 'ayn',
      makhrajGroup: 'الحلق',
      makhrajDetail: 'وسط الحلق',
    ),
    ArabicLetter(
      number: 19,
      arabicLetter: 'غ',
      name: 'الغين',
      nameEnglish: 'ghayn',
      makhrajGroup: 'الحلق',
      makhrajDetail: 'أدنى الحلق',
    ),
    ArabicLetter(
      number: 20,
      arabicLetter: 'ف',
      name: 'الفاء',
      nameEnglish: 'faa',
      makhrajGroup: 'الشفتان',
      makhrajDetail: 'بطن الشفة السفلى مع أطراف الثنايا العليا',
    ),
    ArabicLetter(
      number: 21,
      arabicLetter: 'ق',
      name: 'القاف',
      nameEnglish: 'qaaf',
      makhrajGroup: 'اللسان',
      makhrajDetail: 'أقصى اللسان مع ما يحاذيه من الحنك الأعلى الرخو',
    ),
    ArabicLetter(
      number: 22,
      arabicLetter: 'ك',
      name: 'الكاف',
      nameEnglish: 'kaaf',
      makhrajGroup: 'اللسان',
      makhrajDetail: 'أقصى اللسان أسفل مخرج القاف قليلاً مع الحنك العظمي',
    ),
    ArabicLetter(
      number: 23,
      arabicLetter: 'ل',
      name: 'اللام',
      nameEnglish: 'laam',
      makhrajGroup: 'اللسان',
      makhrajDetail: 'أدنى حافة اللسان إلى منتهى طرفه مع ما يحاذيها من لثة الأسنان العليا',
    ),
    ArabicLetter(
      number: 24,
      arabicLetter: 'م',
      name: 'الميم',
      nameEnglish: 'meem',
      makhrajGroup: 'الشفتان',
      makhrajDetail: 'انطباق الشفتين مع الغنة من الخيشوم',
    ),
    ArabicLetter(
      number: 25,
      arabicLetter: 'ن',
      name: 'النون',
      nameEnglish: 'noon',
      makhrajGroup: 'اللسان',
      makhrajDetail: 'طرف اللسان مع ما يحاذيه من لثة الثنايا العليا مع الغنة',
    ),
    ArabicLetter(
      number: 26,
      arabicLetter: 'هـ',
      name: 'الهاء',
      nameEnglish: 'haa_light',
      makhrajGroup: 'الحلق',
      makhrajDetail: 'أقصى الحلق',
    ),
    ArabicLetter(
      number: 27,
      arabicLetter: 'و',
      name: 'الواو',
      nameEnglish: 'waw',
      makhrajGroup: 'الشفتان',
      makhrajDetail: 'بانضمام الشفتين مع فرجة يسيرة',
    ),
    ArabicLetter(
      number: 28,
      arabicLetter: 'ي',
      name: 'الياء',
      nameEnglish: 'yaa',
      makhrajGroup: 'اللسان',
      makhrajDetail: 'وسط اللسان مع وسط الحنك الأعلى',
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

  /// Constructs the sequential audio tracks for a specific Haraka:
  /// [Letter Name] ➡️ [Haraka Definition] ➡️ [Ex 1] ➡️ ["Another Example" transition] ➡️ [Ex 2] ...
  static List<AudioTrack> getHarakaSequenceTracks(
    int letterNumber,
    LetterHarakaType harakaType, {
    bool includeLetterName = true,
  }) {
    final letter = getByNumber(letterNumber);
    if (letter == null) return [];

    final haraka = letter.getHaraka(harakaType);
    final numStr = letter.number.toString().padLeft(3, '0');
    final tracks = <AudioTrack>[];

    int seqIndex = 1;

    // 1. [Letter Name (from root)]
    if (includeLetterName) {
      tracks.add(AudioTrack(
        id: 'letter_${numStr}_name',
        surahNumber: letter.number,
        surahNameArabic: '${letter.name} - اسم الحرف (${letter.arabicLetter})',
        surahNameEnglish: letter.nameEnglish,
        reciterName: 'مخارج الحروف',
        assetPath: letter.nameAssetPath,
        pageNumber: 0,
        trackType: 'alphabet_segment',
        ayahNumber: seqIndex++,
        harakaName: haraka.nameArabic,
        segmentKind: 'name',
      ));
    }

    // 2. [Haraka Definition]
    tracks.add(AudioTrack(
      id: 'letter_${numStr}_${harakaType.folderName}_def',
      surahNumber: letter.number,
      surahNameArabic: '${letter.name} - تعريف ${haraka.nameArabic} (${haraka.symbol})',
      surahNameEnglish: letter.nameEnglish,
      reciterName: 'مخارج الحروف',
      assetPath: haraka.definitionAssetPath,
      pageNumber: 0,
      trackType: 'alphabet_segment',
      ayahNumber: seqIndex++,
      harakaName: haraka.nameArabic,
      segmentKind: 'definition',
    ));

    // 3. Examples dynamically chained with ["Another Example" transition (from root)]
    for (int i = 0; i < haraka.exampleAssetPaths.length; i++) {
      final exNum = i + 1;
      if (i > 0) {
        // Transition: "مثال آخر"
        tracks.add(AudioTrack(
          id: 'letter_${numStr}_${harakaType.folderName}_trans_$exNum',
          surahNumber: letter.number,
          surahNameArabic: '${letter.name} - مثال آخر (${haraka.symbol})',
          surahNameEnglish: letter.nameEnglish,
          reciterName: 'مخارج الحروف',
          assetPath: letter.anotherExampleAssetPath,
          pageNumber: 0,
          trackType: 'alphabet_segment',
          ayahNumber: seqIndex++,
          harakaName: haraka.nameArabic,
          segmentKind: 'transition',
          exampleNumber: exNum,
        ));
      }

      // Quranic Example
      tracks.add(AudioTrack(
        id: 'letter_${numStr}_${harakaType.folderName}_ex_$exNum',
        surahNumber: letter.number,
        surahNameArabic: '${letter.name} - مثال $exNum (${haraka.symbol})',
        surahNameEnglish: letter.nameEnglish,
        reciterName: 'مخارج الحروف',
        assetPath: haraka.exampleAssetPaths[i],
        pageNumber: 0,
        trackType: 'alphabet_segment',
        ayahNumber: seqIndex++,
        harakaName: haraka.nameArabic,
        segmentKind: 'example',
        exampleNumber: exNum,
      ));
    }

    return tracks;
  }

  /// Constructs the complete full sequence for all 4 Harakat of the letter:
  /// [Letter Name] ➡️
  /// [Sukun Def] ➡️ [Ex 1] ➡️ [Trans] ➡️ [Ex 2] ... ➡️
  /// [Fatha Def] ➡️ [Ex 1] ➡️ [Trans] ➡️ [Ex 2] ... ➡️
  /// [Kasra Def] ➡️ [Ex 1] ➡️ [Trans] ➡️ [Ex 2] ... ➡️
  /// [Damma Def] ➡️ [Ex 1] ➡️ [Trans] ➡️ [Ex 2] ...
  static List<AudioTrack> getLetterFullSequenceTracks(int letterNumber) {
    final letter = getByNumber(letterNumber);
    if (letter == null) return [];

    final tracks = <AudioTrack>[];
    final numStr = letter.number.toString().padLeft(3, '0');
    int seqIndex = 1;

    // Root: [Letter Name]
    tracks.add(AudioTrack(
      id: 'letter_${numStr}_name',
      surahNumber: letter.number,
      surahNameArabic: '${letter.name} - اسم الحرف (${letter.arabicLetter})',
      surahNameEnglish: letter.nameEnglish,
      reciterName: 'مخارج الحروف',
      assetPath: letter.nameAssetPath,
      pageNumber: 0,
      trackType: 'alphabet_segment',
      ayahNumber: seqIndex++,
      segmentKind: 'name',
    ));

    // Sequential 4 Harakat (Sukun, Fatha, Kasra, Damma)
    const harakatOrder = [
      LetterHarakaType.sukun,
      LetterHarakaType.fatha,
      LetterHarakaType.kasra,
      LetterHarakaType.damma,
    ];

    for (final hType in harakatOrder) {
      final harakaTracks = getHarakaSequenceTracks(
        letterNumber,
        hType,
        includeLetterName: false,
      );

      for (final t in harakaTracks) {
        tracks.add(AudioTrack(
          id: t.id,
          surahNumber: t.surahNumber,
          surahNameArabic: t.surahNameArabic,
          surahNameEnglish: t.surahNameEnglish,
          reciterName: t.reciterName,
          assetPath: t.assetPath,
          pageNumber: 0,
          trackType: 'alphabet_segment',
          ayahNumber: seqIndex++,
          harakaName: t.harakaName,
          segmentKind: t.segmentKind,
          exampleNumber: t.exampleNumber,
        ));
      }
    }

    return tracks;
  }

  /// Generate repeat tracks for letter repetition/Hifz mode
  static List<AudioTrack> getLetterRepeatTracks(
    int letterNumber, {
    LetterHarakaType? harakaType,
  }) {
    if (harakaType != null) {
      return getHarakaSequenceTracks(letterNumber, harakaType);
    }
    return getLetterFullSequenceTracks(letterNumber);
  }
}
