import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/data/models/audio_track.dart';
import 'package:rattil/data/models/memorization_settings.dart';
import 'package:rattil/data/sources/ayah_file_to_verse.dart';
import 'package:rattil/features/player/services/verse_service.dart';
import 'package:rattil/features/player/widgets/hifz_progress_bar.dart';
import 'package:rattil/features/player/widgets/letter_repetition_display_widget.dart';
import 'package:rattil/features/player/widgets/pause_countdown_bar.dart';

void main() {
  group('Letter Repetition & Defensive Guard Tests', () {
    test('ayahFileToVerseNumber handles invalid surah numbers safely', () {
      // surahNumber = 0 was causing the crash
      expect(ayahFileToVerseNumber(0, 1), equals(0));
      expect(ayahFileToVerseNumber(-1, 1), equals(0));
      expect(ayahFileToVerseNumber(115, 1), equals(0));
    });

    test('VerseService getVerseText handles invalid surah numbers safely', () {
      final service = VerseService();
      expect(service.getVerseText(0, 1), equals(''));
      expect(service.getVerseText(-5, 2), equals(''));
      expect(service.getVerseText(120, 1), equals(''));
    });

    test('LetterRepetitionDisplayWidget resolves letter number correctly', () {
      const segTrack = AudioTrack(
        id: 'letter_004_seg_4',
        surahNumber: 0,
        surahNameArabic: 'الثاء (ثِ)',
        surahNameEnglish: 'thaa',
        reciterName: 'مخارج الحروف',
        assetPath: 'assets/audio/arabic_alphabet_cuts/004-thaa-4-kasra.mp3',
        pageNumber: 0,
        trackType: 'alphabet_segment',
        ayahNumber: 4,
      );

      final letterNum = LetterRepetitionDisplayWidget.resolveLetterNumber(segTrack);
      expect(letterNum, equals(4));

      const standardTrack = AudioTrack(
        id: 'letter_4',
        surahNumber: 0,
        surahNameArabic: 'الثاء',
        surahNameEnglish: 'thaa',
        reciterName: 'مخارج الحروف',
        assetPath: 'assets/audio/arabic_alphabet/004-thaa.mp3',
        pageNumber: 0,
        trackType: 'alphabet',
      );

      final stdNum = LetterRepetitionDisplayWidget.resolveLetterNumber(standardTrack);
      expect(stdNum, equals(4));
    });

    testWidgets('LetterRepetitionDisplayWidget renders active diacritic and chips', (tester) async {
      int? selectedSegment;

      const track = AudioTrack(
        id: 'letter_004_seg_4',
        surahNumber: 0,
        surahNameArabic: 'الثاء (ثِ)',
        surahNameEnglish: 'thaa',
        reciterName: 'مخارج الحروف',
        assetPath: 'assets/audio/arabic_alphabet_cuts/004-thaa-4-kasra.mp3',
        pageNumber: 0,
        trackType: 'alphabet_segment',
        ayahNumber: 4,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LetterRepetitionDisplayWidget(
              track: track,
              currentSegment: 4,
              totalSegments: 5,
              phase: HifzPhase.listening,
              hideVerses: false,
              onSegmentSelected: (seg) => selectedSegment = seg,
            ),
          ),
        ),
      );

      // Verify listening mode text
      expect(find.text('استمع للحركة'), findsOneWidget);

      // Verify active segment symbol and title
      expect(find.text('الحرف مكسوراً (ثِ)'), findsOneWidget);
      expect(find.text('ثِ'), findsWidgets);

      // Verify footer
      expect(find.text('مقطع 4 من 5'), findsOneWidget);
      expect(find.text('الثاء (اللسان)'), findsOneWidget);

      // Tap on segment 2 (sukun) chip
      await tester.tap(find.text('ثْ'));
      await tester.pump();
      expect(selectedSegment, equals(2));
    });

    testWidgets('LetterRepetitionDisplayWidget renders reciting phase correctly', (tester) async {
      const track = AudioTrack(
        id: 'letter_004_seg_3',
        surahNumber: 0,
        surahNameArabic: 'الثاء (ثَ)',
        surahNameEnglish: 'thaa',
        reciterName: 'مخارج الحروف',
        assetPath: 'assets/audio/arabic_alphabet_cuts/004-thaa-3-fatha.mp3',
        pageNumber: 0,
        trackType: 'alphabet_segment',
        ayahNumber: 3,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LetterRepetitionDisplayWidget(
              track: track,
              currentSegment: 3,
              totalSegments: 5,
              phase: HifzPhase.reciting,
              hideVerses: false,
            ),
          ),
        ),
      );

      expect(find.text('ردد الحركة الآن'), findsOneWidget);
      expect(find.text('الحرف مفتوحاً (ثَ)'), findsOneWidget);
    });

    testWidgets('HifzProgressBar renders مقطع for letters and آية for surahs', (tester) async {
      const state = MemorizationPlaybackState(
        currentAyah: 4,
        totalAyahs: 5,
        currentAyahDuration: Duration(seconds: 2),
      );

      // Letter mode
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HifzProgressBar(
              state: state,
              isLetter: true,
            ),
          ),
        ),
      );

      expect(find.text('مقطع 4 من 5'), findsOneWidget);

      // Surah mode
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HifzProgressBar(
              state: state,
              isLetter: false,
            ),
          ),
        ),
      );

      expect(find.text('آية 4 من 5'), findsOneWidget);
    });

    testWidgets('PauseCountdownBar renders proper prompt for letters', (tester) async {
      const state = MemorizationPlaybackState(
        phase: HifzPhase.reciting,
        pauseRemaining: Duration(seconds: 3),
        pauseTotalDuration: Duration(seconds: 3),
      );

      // Letter mode
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PauseCountdownBar(
              state: state,
              isLetter: true,
            ),
          ),
        ),
      );

      expect(find.text('ردد الحركة الآن'), findsOneWidget);

      // Surah mode
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PauseCountdownBar(
              state: state,
              isLetter: false,
            ),
          ),
        ),
      );

      expect(find.text('ردد الآية الآن'), findsOneWidget);
    });
  });
}
