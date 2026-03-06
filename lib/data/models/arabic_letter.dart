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
}
