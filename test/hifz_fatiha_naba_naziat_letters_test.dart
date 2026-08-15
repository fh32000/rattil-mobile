import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/data/sources/ayah_track_source.dart';
import 'package:rattil/data/sources/arabic_alphabet_data.dart';

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
  });
}
