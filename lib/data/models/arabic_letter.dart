/// نموذج بيانات لحرف عربي مع معلومات المخرج
class ArabicLetter {
  final int number;
  final String arabicLetter;
  final String name; // الاسم بالعربي (الألف)
  final String nameEnglish; // alif
  final String makhrajGroup; // مجموعة المخرج
  final String makhrajDetail; // تفصيل المخرج
  final String assetPath;

  const ArabicLetter({
    required this.number,
    required this.arabicLetter,
    required this.name,
    required this.nameEnglish,
    required this.makhrajGroup,
    required this.makhrajDetail,
    required this.assetPath,
  });

  /// Visual representation for diacritic segment (1 to 5)
  String getSegmentSymbol(int segmentIndex) {
    switch (segmentIndex) {
      case 1:
        return arabicLetter;
      case 2:
        return '$arabicLetter\u0652'; // Sukun
      case 3:
        return '$arabicLetter\u064E'; // Fatha
      case 4:
        return number == 1 ? 'إِ' : '$arabicLetter\u0650'; // Kasra
      case 5:
        return '$arabicLetter\u064F'; // Damma
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
