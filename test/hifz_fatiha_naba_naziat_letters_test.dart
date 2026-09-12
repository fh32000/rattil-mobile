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
      expect(tracks[43].ayahNumber, equals(44));
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

    test('Repetition rule: surahs repeat all ayahs including ayah 1', () {
      // In surahs, track is NOT alphabet_segment
      final surahTracks = AyahTrackSource.getAyahTracks(78);
      final isAlphabetSegment = surahTracks.first.isAlphabetSegment;
      const repeatSettings = 3;

      // Ayah 1
      final isNonRepeatingAyah1 = isAlphabetSegment && 1 == 1;
      final repCountAyah1 = isNonRepeatingAyah1 ? 1 : repeatSettings;
      expect(repCountAyah1, equals(3), reason: 'Surah ayah 1 must repeat 3 times');

      // Ayah 2
      final isNonRepeatingAyah2 = isAlphabetSegment && 2 == 1;
      final repCountAyah2 = isNonRepeatingAyah2 ? 1 : repeatSettings;
      expect(repCountAyah2, equals(3), reason: 'Surah ayah 2 must repeat 3 times');
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
