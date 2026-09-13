import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/data/sources/ayah_file_to_verse.dart';
import 'package:rattil/data/sources/ayah_track_source.dart';
import 'package:rattil/features/player/services/verse_service.dart';

void main() {
  group('Multi-part Ayah Architecture & Parsing Tests', () {
    setUp(() {
      AyahTrackSource.clearCustomSegments();
    });

    tearDown(() {
      AyahTrackSource.clearCustomSegments();
    });

    test('parseFileNames correctly parses and groups multi-part ayahs', () {
      final fileList = [
        '001.mp3',
        '014.mp3',
        '015-1.mp3',
        '015-2.mp3',
        '016.mp3',
        '017.mp3',
      ];

      final segments = AyahTrackSource.parseFileNames(78, fileList);
      expect(segments.length, equals(6));

      // 001.mp3 -> Basmala (verse 0)
      expect(segments[0].fileName, equals('001.mp3'));
      expect(segments[0].verseNumber, equals(0));
      expect(segments[0].partIndex, equals(1));
      expect(segments[0].totalParts, equals(1));
      expect(segments[0].isMultiPart, isFalse);

      // 014.mp3 -> Ayah 14
      expect(segments[1].fileName, equals('014.mp3'));
      expect(segments[1].verseNumber, equals(14));
      expect(segments[1].partIndex, equals(1));
      expect(segments[1].totalParts, equals(1));

      // 015-1.mp3 -> Ayah 15 Part 1 of 2
      expect(segments[2].fileName, equals('015-1.mp3'));
      expect(segments[2].verseNumber, equals(15));
      expect(segments[2].partIndex, equals(1));
      expect(segments[2].totalParts, equals(2));
      expect(segments[2].isMultiPart, isTrue);

      // 015-2.mp3 -> Ayah 15 Part 2 of 2
      expect(segments[3].fileName, equals('015-2.mp3'));
      expect(segments[3].verseNumber, equals(15));
      expect(segments[3].partIndex, equals(2));
      expect(segments[3].totalParts, equals(2));
      expect(segments[3].isMultiPart, isTrue);

      // 016.mp3 -> Ayah 16
      expect(segments[4].fileName, equals('016.mp3'));
      expect(segments[4].verseNumber, equals(16));
      expect(segments[4].partIndex, equals(1));
      expect(segments[4].totalParts, equals(1));
      expect(segments[4].isMultiPart, isFalse);

      // 017.mp3 -> Ayah 17
      expect(segments[5].fileName, equals('017.mp3'));
      expect(segments[5].verseNumber, equals(17));
    });

    test('parseFileNames supports 3-part and 4-part long ayahs', () {
      final fileList = [
        '001.mp3',
        '020-1.mp3',
        '020-2.mp3',
        '020-3.mp3',
        '021-1.mp3',
        '021-2.mp3',
        '021-3.mp3',
        '021-4.mp3',
        '022.mp3',
      ];

      final segments = AyahTrackSource.parseFileNames(78, fileList);
      final seg20 = segments.where((s) => s.verseNumber == 20).toList();
      expect(seg20.length, equals(3));
      for (int p = 0; p < 3; p++) {
        expect(seg20[p].partIndex, equals(p + 1));
        expect(seg20[p].totalParts, equals(3));
      }

      final seg21 = segments.where((s) => s.verseNumber == 21).toList();
      expect(seg21.length, equals(4));
      for (int p = 0; p < 4; p++) {
        expect(seg21[p].partIndex, equals(p + 1));
        expect(seg21[p].totalParts, equals(4));
      }
    });

    test('ayahFileToVerseNumber and VerseService return same verse for all parts', () {
      final segments = [
        const AyahTrackSegment(fileName: '001.mp3', verseNumber: 0),
        const AyahTrackSegment(fileName: '014.mp3', verseNumber: 14),
        const AyahTrackSegment(fileName: '015-1.mp3', verseNumber: 15, partIndex: 1, totalParts: 2),
        const AyahTrackSegment(fileName: '015-2.mp3', verseNumber: 15, partIndex: 2, totalParts: 2),
        const AyahTrackSegment(fileName: '016.mp3', verseNumber: 16),
      ];

      AyahTrackSource.registerCustomSegments(78, segments);

      // Track 1: Basmala
      expect(ayahFileToVerseNumber(78, 1), equals(0));

      // Track 2: Ayah 14
      expect(ayahFileToVerseNumber(78, 2), equals(14));

      // Track 3: Ayah 15 Part 1
      expect(ayahFileToVerseNumber(78, 3), equals(15));

      // Track 4: Ayah 15 Part 2
      expect(ayahFileToVerseNumber(78, 4), equals(15));

      // Track 5: Ayah 16
      expect(ayahFileToVerseNumber(78, 5), equals(16));

      // VerseService
      final service = VerseService();
      final textPart1 = service.getTextForAudioIndex(78, 3);
      final textPart2 = service.getTextForAudioIndex(78, 4);
      expect(textPart1, isNotEmpty);
      expect(textPart1, equals(textPart2), reason: 'Both parts of Ayah 15 must display identical Quran verse text');

      // Part Info
      final part1Info = service.getPartInfoForAudioIndex(78, 3);
      expect(part1Info, isNotNull);
      expect(part1Info!.partIndex, equals(1));
      expect(part1Info.totalParts, equals(2));
      expect(part1Info.isMultiPart, isTrue);

      final part2Info = service.getPartInfoForAudioIndex(78, 4);
      expect(part2Info, isNotNull);
      expect(part2Info!.partIndex, equals(2));
      expect(part2Info.totalParts, equals(2));
      expect(part2Info.isMultiPart, isTrue);

      final track5Info = service.getPartInfoForAudioIndex(78, 5);
      expect(track5Info, isNotNull);
      expect(track5Info!.isMultiPart, isFalse);
    });

    test('AudioTrack generates correct multi-part metadata and displayName', () {
      final segments = [
        const AyahTrackSegment(fileName: '001.mp3', verseNumber: 0),
        const AyahTrackSegment(fileName: '015-1.mp3', verseNumber: 15, partIndex: 1, totalParts: 2),
        const AyahTrackSegment(fileName: '015-2.mp3', verseNumber: 15, partIndex: 2, totalParts: 2),
      ];

      AyahTrackSource.registerCustomSegments(78, segments);
      final tracks = AyahTrackSource.getAyahTracks(78);

      expect(tracks.length, equals(3));
      final trackPart1 = tracks[1];
      expect(trackPart1.verseNumber, equals(15));
      expect(trackPart1.partIndex, equals(1));
      expect(trackPart1.totalParts, equals(2));
      expect(trackPart1.isMultiPart, isTrue);
      expect(trackPart1.partLabel, equals('مقطع 1 من 2'));
      expect(trackPart1.displayName, contains('(مقطع 1/2)'));

      final trackPart2 = tracks[2];
      expect(trackPart2.verseNumber, equals(15));
      expect(trackPart2.partIndex, equals(2));
      expect(trackPart2.totalParts, equals(2));
      expect(trackPart2.isMultiPart, isTrue);
      expect(trackPart2.partLabel, equals('مقطع 2 من 2'));
      expect(trackPart2.displayName, contains('(مقطع 2/2)'));
    });

    test('Repetition rule: Basmala plays once, but both parts of multi-part ayah repeat', () {
      const repeatSetting = 3;

      final segments = [
        const AyahTrackSegment(fileName: '001.mp3', verseNumber: 0),
        const AyahTrackSegment(fileName: '015-1.mp3', verseNumber: 15, partIndex: 1, totalParts: 2),
        const AyahTrackSegment(fileName: '015-2.mp3', verseNumber: 15, partIndex: 2, totalParts: 2),
      ];
      AyahTrackSource.registerCustomSegments(78, segments);
      final tracks = AyahTrackSource.getAyahTracks(78);

      // Track 1: Basmala
      final track1 = tracks[0];
      final isNonRepeatingBasmala = track1.surahNumber != 1 && (track1.verseNumber == 0 || track1.ayahNumber == 1);
      final repCountBasmala = isNonRepeatingBasmala ? 1 : repeatSetting;
      expect(repCountBasmala, equals(1), reason: 'Basmala in Surah 78 must play only once');

      // Track 2: Ayah 15 Part 1
      final track2 = tracks[1];
      final isNonRepeatingPart1 = track2.surahNumber != 1 && (track2.verseNumber == 0);
      final repCountPart1 = isNonRepeatingPart1 ? 1 : repeatSetting;
      expect(repCountPart1, equals(3), reason: 'Ayah 15 Part 1 must repeat 3 times');

      // Track 3: Ayah 15 Part 2
      final track3 = tracks[2];
      final isNonRepeatingPart2 = track3.surahNumber != 1 && (track3.verseNumber == 0);
      final repCountPart2 = isNonRepeatingPart2 ? 1 : repeatSetting;
      expect(repCountPart2, equals(3), reason: 'Ayah 15 Part 2 must repeat 3 times');
    });

    test('Surah 78 default segments has all 44 clips mapped to canonical verses 1..40 and Basmala', () {
      final segments = AyahTrackSource.getSegments(78);
      expect(segments.length, equals(44));

      // Track 1: Basmala (000.mp3, verse 0)
      expect(segments[0].fileName, equals('000.mp3'));
      expect(segments[0].verseNumber, equals(0));

      // Tracks 2..14: Ayahs 1..13 (001.mp3 .. 013.mp3)
      for (int i = 1; i <= 13; i++) {
        expect(segments[i].verseNumber, equals(i));
        expect(segments[i].fileName, equals('${i.toString().padLeft(3, '0')}.mp3'));
        expect(segments[i].isMultiPart, isFalse);
      }

      // Track 15: Ayah 14 Part 1 (014-1.mp3)
      expect(segments[14].fileName, equals('014-1.mp3'));
      expect(segments[14].verseNumber, equals(14));
      expect(segments[14].partIndex, equals(1));
      expect(segments[14].totalParts, equals(2));

      // Track 16: Ayah 14 Part 2 (014-2.mp3)
      expect(segments[15].fileName, equals('014-2.mp3'));
      expect(segments[15].verseNumber, equals(14));
      expect(segments[15].partIndex, equals(2));
      expect(segments[15].totalParts, equals(2));

      // Tracks 17..38: Ayahs 15..36 (015.mp3 .. 036.mp3)
      for (int i = 16; i < 38; i++) {
        final verse = i - 1; // 15..36
        expect(segments[i].verseNumber, equals(verse));
        expect(segments[i].fileName, equals('${verse.toString().padLeft(3, '0')}.mp3'));
        expect(segments[i].isMultiPart, isFalse);
      }

      // Track 39: Ayah 37 Part 1 (037-1.mp3)
      expect(segments[38].fileName, equals('037-1.mp3'));
      expect(segments[38].verseNumber, equals(37));
      expect(segments[38].partIndex, equals(1));
      expect(segments[38].totalParts, equals(2));

      // Track 40: Ayah 37 Part 2 (037-2.mp3)
      expect(segments[39].fileName, equals('037-2.mp3'));
      expect(segments[39].verseNumber, equals(37));
      expect(segments[39].partIndex, equals(2));
      expect(segments[39].totalParts, equals(2));

      // Track 41: Ayah 38 Part 1 (038-1.mp3)
      expect(segments[40].fileName, equals('038-1.mp3'));
      expect(segments[40].verseNumber, equals(38));
      expect(segments[40].partIndex, equals(1));
      expect(segments[40].totalParts, equals(2));

      // Track 42: Ayah 38 Part 2 (038-2.mp3)
      expect(segments[41].fileName, equals('038-2.mp3'));
      expect(segments[41].verseNumber, equals(38));
      expect(segments[41].partIndex, equals(2));
      expect(segments[41].totalParts, equals(2));

      // Track 43: Ayah 39 (039.mp3)
      expect(segments[42].fileName, equals('039.mp3'));
      expect(segments[42].verseNumber, equals(39));
      expect(segments[42].isMultiPart, isFalse);

      // Track 44: Ayah 40 (040.mp3) - the final verse!
      expect(segments[43].fileName, equals('040.mp3'));
      expect(segments[43].verseNumber, equals(40));
      expect(segments[43].isMultiPart, isFalse);
    });
  });
}
