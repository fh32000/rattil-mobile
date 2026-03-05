class Surah {
  final int number;
  final String nameArabic;
  final String nameEnglish;
  final int versesCount;
  final int pageStart;
  final String revelationType; // مكية / مدنية
  final String juzName;

  const Surah({
    required this.number,
    required this.nameArabic,
    required this.nameEnglish,
    required this.versesCount,
    required this.pageStart,
    required this.revelationType,
    this.juzName = 'جزء عمّ',
  });
}
