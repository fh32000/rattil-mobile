/// نموذج بيانات لحرف عربي مع معلومات المخرج والحركات والأمثلة الصوتية المتعددة
enum LetterHarakaType {
  sukun,
  fatha,
  kasra,
  damma;

  String get arabicName {
    switch (this) {
      case LetterHarakaType.sukun:
        return 'السكون';
      case LetterHarakaType.fatha:
        return 'الفتحة';
      case LetterHarakaType.kasra:
        return 'الكسرة';
      case LetterHarakaType.damma:
        return 'الضمة';
    }
  }

  String get folderName => name;
}

class LetterHaraka {
  final LetterHarakaType type;
  final String nameArabic;
  final String symbol;
  final String definitionAssetPath;
  final List<String> exampleAssetPaths;

  const LetterHaraka({
    required this.type,
    required this.nameArabic,
    required this.symbol,
    required this.definitionAssetPath,
    required this.exampleAssetPaths,
  });

  int get exampleCount => exampleAssetPaths.length;
}

class ArabicLetter {
  final int number;
  final String arabicLetter;
  final String name; // الاسم بالعربي (الألف)
  final String nameEnglish; // alif
  final String makhrajGroup; // مجموعة المخرج
  final String makhrajDetail; // تفصيل المخرج

  const ArabicLetter({
    required this.number,
    required this.arabicLetter,
    required this.name,
    required this.nameEnglish,
    required this.makhrajGroup,
    required this.makhrajDetail,
  });

  String get folderName => '${number.toString().padLeft(3, '0')}_$nameEnglish';
  String get rootAssetDir => 'assets/audio/arabic_alphabet/$folderName';
  String get nameAssetPath => '$rootAssetDir/name.mp3';
  String get anotherExampleAssetPath => '$rootAssetDir/another_example.mp3';

  /// مسار ملف التعريف الصوتي للحرف (متوافق مع المشغل)
  String get assetPath => nameAssetPath;

  int getExampleCountForHaraka(LetterHarakaType type) {
    if (number == 21 && type == LetterHarakaType.fatha) {
      return 5;
    }
    return 4;
  }

  String getHarakaSymbol(LetterHarakaType type) {
    switch (type) {
      case LetterHarakaType.sukun:
        return '$arabicLetter\u0652';
      case LetterHarakaType.fatha:
        return '$arabicLetter\u064E';
      case LetterHarakaType.kasra:
        return number == 1 ? 'إِ' : '$arabicLetter\u0650';
      case LetterHarakaType.damma:
        return '$arabicLetter\u064F';
    }
  }

  LetterHaraka getHaraka(LetterHarakaType type) {
    final count = getExampleCountForHaraka(type);
    final hDir = '$rootAssetDir/${type.folderName}';
    return LetterHaraka(
      type: type,
      nameArabic: type.arabicName,
      symbol: getHarakaSymbol(type),
      definitionAssetPath: '$hDir/definition.mp3',
      exampleAssetPaths:
          List.generate(count, (i) => '$hDir/example_${i + 1}.mp3'),
    );
  }

  List<LetterHaraka> get allHarakat => [
        getHaraka(LetterHarakaType.sukun),
        getHaraka(LetterHarakaType.fatha),
        getHaraka(LetterHarakaType.kasra),
        getHaraka(LetterHarakaType.damma),
      ];

  /// Visual representation for diacritic segment (1 to 5)
  String getSegmentSymbol(int segmentIndex) {
    switch (segmentIndex) {
      case 1:
        return arabicLetter;
      case 2:
        return getHarakaSymbol(LetterHarakaType.sukun);
      case 3:
        return getHarakaSymbol(LetterHarakaType.fatha);
      case 4:
        return getHarakaSymbol(LetterHarakaType.kasra);
      case 5:
        return getHarakaSymbol(LetterHarakaType.damma);
      default:
        return arabicLetter;
    }
  }

  /// Label description for segment (1 to 5)
  String getSegmentTitle(int segmentIndex) {
    switch (segmentIndex) {
      case 1:
        return 'اسم الحرف ($arabicLetter)';
      case 2:
        return 'الحرف ساكناً (${getSegmentSymbol(2)})';
      case 3:
        return 'الحرف مفتوحاً (${getSegmentSymbol(3)})';
      case 4:
        return 'الحرف مكسوراً (${getSegmentSymbol(4)})';
      case 5:
        return 'الحرف مضموماً (${getSegmentSymbol(5)})';
      default:
        return name;
    }
  }
}
