class AudioTrack {
  final String id;
  final int surahNumber;
  final String surahNameArabic;
  final String surahNameEnglish;
  final String reciterName;
  final String assetPath;
  final int pageNumber;
  final String trackType; // 'surah', 'alphabet', 'ayah', or 'alphabet_segment'
  final int? ayahNumber;
  final int? verseNumber;
  final int partIndex;
  final int totalParts;
  final String? harakaName; // e.g. 'السكون', 'الفتحة', 'الكسرة', 'الضمة'
  final String? segmentKind; // 'name', 'definition', 'transition', 'example'
  final int? exampleNumber; // 1, 2, 3...

  const AudioTrack({
    required this.id,
    required this.surahNumber,
    required this.surahNameArabic,
    required this.surahNameEnglish,
    required this.reciterName,
    required this.assetPath,
    required this.pageNumber,
    this.trackType = 'surah',
    this.ayahNumber,
    this.verseNumber,
    this.partIndex = 1,
    this.totalParts = 1,
    this.harakaName,
    this.segmentKind,
    this.exampleNumber,
  });

  bool get isSurah => trackType == 'surah';
  bool get isAyah => trackType == 'ayah';
  bool get isLetter =>
      trackType == 'alphabet' || trackType == 'alphabet_segment';
  bool get isAlphabetSegment => trackType == 'alphabet_segment';
  bool get isMultiPart => totalParts > 1;
  String get partLabel => isMultiPart ? 'مقطع $partIndex من $totalParts' : '';

  bool get isLetterName => segmentKind == 'name';
  bool get isHarakaDefinition => segmentKind == 'definition';
  bool get isTransition => segmentKind == 'transition';
  bool get isExample => segmentKind == 'example';

  String get displayName {
    if (isAyah && ayahNumber != null) {
      if (isMultiPart) {
        final vNum = verseNumber ?? ayahNumber;
        return '$surahNameArabic - آية $vNum (مقطع $partIndex/$totalParts)';
      }
      return '$surahNameArabic - $ayahNumber';
    }
    if (isAlphabetSegment) {
      return surahNameArabic;
    }
    return isSurah ? 'سورة $surahNameArabic' : surahNameArabic;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioTrack && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
