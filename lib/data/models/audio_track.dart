class AudioTrack {
  final String id;
  final int surahNumber;
  final String surahNameArabic;
  final String surahNameEnglish;
  final String reciterName;
  final String assetPath;
  final int pageNumber;
  final String trackType; // 'surah' or 'alphabet'

  const AudioTrack({
    required this.id,
    required this.surahNumber,
    required this.surahNameArabic,
    required this.surahNameEnglish,
    required this.reciterName,
    required this.assetPath,
    required this.pageNumber,
    this.trackType = 'surah',
  });

  bool get isSurah => trackType == 'surah';

  /// اسم العرض: "سورة النبأ" للسور، "حرف الخاء" للحروف
  String get displayName => isSurah ? 'سورة $surahNameArabic' : surahNameArabic;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioTrack && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
