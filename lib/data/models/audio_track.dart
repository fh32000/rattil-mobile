class AudioTrack {
  final String id;
  final int surahNumber;
  final String surahNameArabic;
  final String surahNameEnglish;
  final String reciterName;
  final String assetPath;
  final int pageNumber;
  final String trackType; // 'surah', 'alphabet', or 'ayah'
  final int? ayahNumber;

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
  });

  bool get isSurah => trackType == 'surah';
  bool get isAyah => trackType == 'ayah';

  String get displayName {
    if (isAyah && ayahNumber != null) {
      return '$surahNameArabic - $ayahNumber';
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
