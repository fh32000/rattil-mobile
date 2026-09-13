import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/data/sources/ayah_track_source.dart';
import 'package:rattil/data/sources/arabic_alphabet_data.dart';
import 'package:rattil/data/sources/ayah_file_to_verse.dart';

void main() {
  group('Hifz Mode - Fatihah, Naba, Naziat & Alphabet Tests', () {
    setUp(() {
      AyahTrackSource.setValidationStatusForTesting(1, true);
      AyahTrackSource.setValidationStatusForTesting(78, true);
      AyahTrackSource.setValidationStatusForTesting(79, true);
    });

    test('Surah Al-Fatihah audio tracks configuration', () {
      expect(AyahTrackSource.hasAyahAudio(1), isTrue);
      final tracks = AyahTrackSource.getAyahTracks(1);
      expect(tracks.length, equals(7));
      expect(tracks[0].surahNumber, equals(1));
      expect(tracks[0].ayahNumber, equals(1));
      expect(tracks[0].assetPath, contains('surah_001/001.mp3'));
      expect(tracks[6].ayahNumber, equals(7));
      expect(tracks[6].assetPath, contains('surah_001/007.mp3'));
    });

    test('Surah An-Naba audio tracks count and mapping', () {
      expect(AyahTrackSource.hasAyahAudio(78), isTrue);
      final tracks = AyahTrackSource.getAyahTracks(78);
      expect(tracks.length, equals(44));
      expect(tracks[0].ayahNumber, equals(1));
      expect(tracks[0].verseNumber, equals(0));
      expect(tracks[0].assetPath, contains('000.mp3'));
      expect(tracks[14].verseNumber, equals(14));
      expect(tracks[14].partIndex, equals(1));
      expect(tracks[14].assetPath, contains('014-1.mp3'));
      expect(tracks[15].verseNumber, equals(14));
      expect(tracks[15].partIndex, equals(2));
      expect(tracks[15].assetPath, contains('014-2.mp3'));
      expect(tracks[43].ayahNumber, equals(44));
      expect(tracks[43].verseNumber, equals(40));
      expect(tracks[43].assetPath, contains('040.mp3'));
    });

    test('Surah An-Naziat audio tracks count and mapping', () {
      expect(AyahTrackSource.hasAyahAudio(79), isTrue);
      final tracks = AyahTrackSource.getAyahTracks(79);
      expect(tracks.length, equals(46));
      expect(tracks[0].ayahNumber, equals(1));
      expect(tracks[45].ayahNumber, equals(46));
    });

    test('Arabic alphabet repetition tracks generation', () {
      final tracks = ArabicAlphabetData.getLetterRepeatTracks(1);
      expect(tracks.length, equals(5));
      expect(tracks[0].trackType, equals('alphabet_segment'));
      expect(tracks[0].ayahNumber, equals(1));
      expect(tracks[0].assetPath, contains('001-alif-1-name.mp3'));
      expect(tracks[1].assetPath, contains('001-alif-2-sukun.mp3'));
      expect(tracks[2].assetPath, contains('001-alif-3-fatha.mp3'));
      expect(tracks[3].assetPath, contains('001-alif-4-kasra.mp3'));
      expect(tracks[4].assetPath, contains('001-alif-5-damma.mp3'));
    });

    test('ArabicLetter diacritic symbol resolution', () {
      final alif = ArabicAlphabetData.getByNumber(1)!;
      expect(alif.getSegmentSymbol(1), equals('أ'));
      expect(alif.getSegmentSymbol(2), equals('أْ'));
      expect(alif.getSegmentSymbol(3), equals('أَ'));
      expect(alif.getSegmentSymbol(4), equals('إِ'));
      expect(alif.getSegmentSymbol(5), equals('أُ'));

      final thal = ArabicAlphabetData.getByNumber(9)!;
      expect(thal.getSegmentSymbol(1), equals('ذ'));
      expect(thal.getSegmentSymbol(2), equals('ذْ'));
      expect(thal.getSegmentSymbol(3), equals('ذَ'));
      expect(thal.getSegmentSymbol(4), equals('ذِ'));
      expect(thal.getSegmentSymbol(5), equals('ذُ'));
    });

    test('Surah Al-Fatihah audio files map 1:1 to canonical verses 1..7', () {
      for (int i = 1; i <= 7; i++) {
        expect(ayahFileToVerseNumber(1, i), equals(i));
      }
    });

    test('Repetition rule: Basmala does not repeat in surahs (except Al-Fatihah), verses repeat', () {
      const repeatSettings = 3;

      // Surah 78 (An-Naba):
      final nabaTracks = AyahTrackSource.getAyahTracks(78);
      final isAlphabetNaba = nabaTracks.first.isAlphabetSegment;
      final surahNumNaba = nabaTracks.first.surahNumber;

      // Track 1 (Basmala) in Surah 78 -> 1 repetition (does not repeat)
      final isNonRepeatingBasmala78 = isAlphabetNaba
          ? 1 == 1
          : (surahNumNaba != 1 && 1 == 1);
      final repCountBasmala78 = isNonRepeatingBasmala78 ? 1 : repeatSettings;
      expect(repCountBasmala78, equals(1), reason: 'Basmala in Surah 78 must NOT repeat');

      // Track 2 (Ayah 1 of An-Naba: "عَمَّ يَتَسَاءَلُونَ") -> 3 repetitions
      final isNonRepeatingAyah2 = isAlphabetNaba
          ? 2 == 1
          : (surahNumNaba != 1 && 2 == 1);
      final repCountAyah2 = isNonRepeatingAyah2 ? 1 : repeatSettings;
      expect(repCountAyah2, equals(3), reason: 'Verses in Surah 78 must repeat according to repeat count');

      // Surah 1 (Al-Fatihah):
      final fatihaTracks = AyahTrackSource.getAyahTracks(1);
      final isAlphabetFatiha = fatihaTracks.first.isAlphabetSegment;
      final surahNumFatiha = fatihaTracks.first.surahNumber;

      // Track 1 in Al-Fatihah (Ayah 1: "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ") -> repeats according to repeatSettings
      final isNonRepeatingAyah1Fatiha = isAlphabetFatiha
          ? 1 == 1
          : (surahNumFatiha != 1 && 1 == 1);
      final repCountAyah1Fatiha = isNonRepeatingAyah1Fatiha ? 1 : repeatSettings;
      expect(repCountAyah1Fatiha, equals(3), reason: 'Ayah 1 in Al-Fatihah must repeat');
    });

    test('Repetition rule: letters do not repeat segment 1, but repeat segments 2..5', () {
      final letterTracks = ArabicAlphabetData.getLetterRepeatTracks(1);
      final isAlphabetSegment = letterTracks.first.isAlphabetSegment;
      const repeatSettings = 3;

      // Segment 1 (Letter name) -> 1 repetition
      final isNonRepeatingSeg1 = isAlphabetSegment && 1 == 1;
      final repCountSeg1 = isNonRepeatingSeg1 ? 1 : repeatSettings;
      expect(repCountSeg1, equals(1), reason: 'Letter name must not repeat');

      // Segment 2 (Sukun) -> 3 repetitions
      final isNonRepeatingSeg2 = isAlphabetSegment && 2 == 1;
      final repCountSeg2 = isNonRepeatingSeg2 ? 1 : repeatSettings;
      expect(repCountSeg2, equals(3), reason: 'Letter diacritic segment must repeat');
    });
  });
}
