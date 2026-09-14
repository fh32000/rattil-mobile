import 'package:flutter/services.dart' show rootBundle, AssetBundle, AssetManifest;
import '../models/audio_track.dart';
import '../../core/constants/app_constants.dart';
import 'juz_amma_data.dart';

/// Source of ayah-level audio tracks for Memorization (Hifz) Mode.
///
/// ### Validation
///
/// Validation is lazy and per-surah.  When [hasAyahAudio] is called for a
/// surah that hasn't been validated yet, it returns `true` optimistically
/// (the surah is in [ayahFileCounts]) and kicks off a background validation.
/// Once the background check completes, the cached result is used for
/// subsequent calls.
///
/// This eliminates the 70-call startup bottleneck that was causing ANRs on
/// low-end devices.
class AyahTrackSource {
  AyahTrackSource._();

  static const String _basePath = 'assets/audio/juz_amma_ayahs';

  /// Actual number of ayah audio files per surah
  static const Map<int, int> ayahFileCounts = {
    1: 7,
    78: 44,
    79: 47,
    80: 43,
    81: 30,
    82: 20,
    83: 39,
    84: 27,
    85: 23,
    86: 18,
    87: 21,
    88: 27,
    89: 32,
    90: 23,
    91: 16,
    92: 22,
    93: 12,
    94: 9,
    95: 10,
    96: 20,
    97: 7,
    98: 9,
    99: 9,
    100: 12,
    101: 12,
    102: 9,
    103: 4,
    104: 10,
    105: 6,
    106: 5,
    107: 8,
    108: 4,
    109: 7,
    110: 4,
    111: 6,
    112: 5,
    113: 6,
    114: 7,
  };

  /// Surahs whose audio files have been verified at runtime.
  /// `true` = validated & OK, `false` = validated & FAILED.
  static final Map<int, bool> _validationCache = {};

  /// For testing: manually set or override validation status.
  static void setValidationStatusForTesting(int surahNumber, bool isValid) {
    _validationCache[surahNumber] = isValid;
  }

  /// Whether a background validation is in-flight for a surah.
  static final Set<int> _validating = {};

  /// Whether Memorization Mode is available for [surahNumber].
  ///
  /// Synchronous check: returns the cached validation result if available,
  /// otherwise returns `true` optimistically (surah is in [ayahFileCounts])
  /// and triggers a background validation.
  static bool hasAyahAudio(int surahNumber) {
    if (!ayahFileCounts.containsKey(surahNumber)) return false;

    // Already validated?
    if (_validationCache.containsKey(surahNumber)) {
      return _validationCache[surahNumber]!;
    }

    // Not yet validated — trigger background check, return true optimistically
    _validateSurahInBackground(surahNumber);
    return true;
  }

  /// Validates a single surah in the background (fire-and-forget).
  static void _validateSurahInBackground(int surahNumber) {
    if (_validating.contains(surahNumber)) return;
    _validating.add(surahNumber);

    () async {
      final count = ayahFileCounts[surahNumber]!;
      final first = ayahAssetPath(surahNumber, 1);
      final last = ayahAssetPath(surahNumber, count);

      try {
        await rootBundle.load(first);
        await rootBundle.load(last);
        _validationCache[surahNumber] = true;
        // ignore: avoid_print
        print('[AyahTrackSource] Surah $surahNumber validated ($count files)');
      } catch (_) {
        _validationCache[surahNumber] = false;
        // ignore: avoid_print
        print(
          '[AyahTrackSource] Surah $surahNumber SKIPPED — '
          'file(s) not bundled',
        );
      } finally {
        _validating.remove(surahNumber);
      }
    }();
  }

  /// Registry of custom/parsed segments per surah.
  static final Map<int, List<AyahTrackSegment>> _surahSegments = {};

  /// Regex matching filenames like '001.mp3', '015-1.mp3', '15-2.mp3', '015_1.mp3'
  static final RegExp _fileRegex = RegExp(r'^(\d+)(?:[-_](\d+))?\.mp3$');

  /// Register custom segments for a surah (e.g. For surahs with split ayahs).
  static void registerCustomSegments(
    int surahNumber,
    List<AyahTrackSegment> segments,
  ) {
    _surahSegments[surahNumber] = List.unmodifiable(segments);
  }

  /// Check whether custom segments are registered for [surahNumber].
  static bool hasCustomTracks(int surahNumber) =>
      _surahSegments.containsKey(surahNumber);

  /// Clears custom segments (useful in testing).
  static void clearCustomSegments() => _surahSegments.clear();

  /// Parse a list of audio file names into ordered [AyahTrackSegment]s.
  /// Supports:
  /// - Standard: `['001.mp3', '002.mp3', ...]`
  /// - Multi-part: `['001.mp3', ..., '015-1.mp3', '015-2.mp3', '016.mp3', ...]`
  static List<AyahTrackSegment> parseFileNames(
    int surahNumber,
    List<String> fileNames,
  ) {
    if (fileNames.isEmpty) return [];

    final parsed = <_RawFileInfo>[];
    for (final name in fileNames) {
      final baseName = name.split('/').last;
      final match = _fileRegex.firstMatch(baseName);
      if (match != null) {
        final base = int.parse(match.group(1)!);
        final part = match.group(2) != null ? int.parse(match.group(2)!) : 1;
        parsed.add(_RawFileInfo(baseName, base, part));
      } else if (baseName.toLowerCase().contains('basmala') ||
          baseName.startsWith('000')) {
        parsed.add(_RawFileInfo(baseName, 0, 1));
      }
    }

    parsed.sort((a, b) {
      final cmp = a.base.compareTo(b.base);
      if (cmp != 0) return cmp;
      return a.part.compareTo(b.part);
    });

    final partCounts = <int, int>{};
    for (final f in parsed) {
      partCounts[f.base] = (partCounts[f.base] ?? 0) + 1;
    }

    final hasMultiPart = parsed.any((f) =>
        f.fileName.contains('-') ||
        f.fileName.contains('_') ||
        (partCounts[f.base] ?? 0) > 1);

    final segments = <AyahTrackSegment>[];
    for (int i = 0; i < parsed.length; i++) {
      final f = parsed[i];
      int verseNum;

      if (surahNumber == 1) {
        verseNum = f.base;
      } else if (hasMultiPart) {
        // In multi-part naming mode (where files like 15-1, 15-2, 16 exist):
        if (f.base == 0 || (i == 0 && f.base == 1 && partCounts[f.base] == 1)) {
          verseNum = 0; // Basmala
        } else {
          verseNum = f.base;
        }
      } else {
        // Standard sequential mode (001.mp3 = basmala, 002.mp3 = verse 1...)
        verseNum = i; // 0 for basmala, 1 for verse 1...
      }

      segments.add(AyahTrackSegment(
        fileName: f.fileName,
        verseNumber: verseNum,
        partIndex: f.part,
        totalParts: partCounts[f.base] ?? 1,
      ));
    }

    return segments;
  }

  /// Scans the asset bundle manifest to dynamically discover all surah audio files.
  static Future<void> initFromAssetBundle([AssetBundle? bundle]) async {
    try {
      final b = bundle ?? rootBundle;
      final manifest = await AssetManifest.loadFromAssetBundle(b);
      final assets = manifest.listAssets();
      final surahFiles = <int, List<String>>{};

      final pathRegex = RegExp(
          r'^assets/audio/juz_amma_ayahs/surah_(\d+)/([^/]+\.mp3)$');
      for (final asset in assets) {
        final match = pathRegex.firstMatch(asset);
        if (match != null) {
          final surahNum = int.parse(match.group(1)!);
          final fileName = match.group(2)!;
          surahFiles.putIfAbsent(surahNum, () => []).add(fileName);
        }
      }

      for (final entry in surahFiles.entries) {
        final segments = parseFileNames(entry.key, entry.value);
        if (segments.isNotEmpty) {
          registerCustomSegments(entry.key, segments);
        }
      }
    } catch (_) {
      // Fallback silently to static definitions
    }
  }

  /// Returns the ordered segments for a surah.
  static List<AyahTrackSegment> getSegments(int surahNumber) {
    if (_surahSegments.containsKey(surahNumber)) {
      return _surahSegments[surahNumber]!;
    }

    if (surahNumber == 78) {
      final segments = <AyahTrackSegment>[
        const AyahTrackSegment(fileName: '000.mp3', verseNumber: 0),
        for (int i = 1; i <= 13; i++)
          AyahTrackSegment(
            fileName: '${i.toString().padLeft(3, '0')}.mp3',
            verseNumber: i,
          ),
        const AyahTrackSegment(
          fileName: '014-1.mp3',
          verseNumber: 14,
          partIndex: 1,
          totalParts: 2,
        ),
        const AyahTrackSegment(
          fileName: '014-2.mp3',
          verseNumber: 14,
          partIndex: 2,
          totalParts: 2,
        ),
        for (int i = 15; i <= 36; i++)
          AyahTrackSegment(
            fileName: '${i.toString().padLeft(3, '0')}.mp3',
            verseNumber: i,
          ),
        const AyahTrackSegment(
          fileName: '037-1.mp3',
          verseNumber: 37,
          partIndex: 1,
          totalParts: 2,
        ),
        const AyahTrackSegment(
          fileName: '037-2.mp3',
          verseNumber: 37,
          partIndex: 2,
          totalParts: 2,
        ),
        const AyahTrackSegment(
          fileName: '038-1.mp3',
          verseNumber: 38,
          partIndex: 1,
          totalParts: 2,
        ),
        const AyahTrackSegment(
          fileName: '038-2.mp3',
          verseNumber: 38,
          partIndex: 2,
          totalParts: 2,
        ),
        const AyahTrackSegment(
          fileName: '039.mp3',
          verseNumber: 39,
        ),
        const AyahTrackSegment(
          fileName: '040.mp3',
          verseNumber: 40,
        ),
      ];
      return segments;
    }

    if (surahNumber == 79) {
      return <AyahTrackSegment>[
        const AyahTrackSegment(fileName: '000.mp3', verseNumber: 0),
        for (int i = 1; i <= 46; i++)
          AyahTrackSegment(
            fileName: '${i.toString().padLeft(3, '0')}.mp3',
            verseNumber: i,
          ),
      ];
    }

    if (surahNumber == 83) {
      return <AyahTrackSegment>[
        const AyahTrackSegment(fileName: '000.mp3', verseNumber: 0),
        for (int i = 1; i <= 12; i++)
          AyahTrackSegment(
            fileName: '${i.toString().padLeft(3, '0')}.mp3',
            verseNumber: i,
          ),
        const AyahTrackSegment(
          fileName: '013-1.mp3',
          verseNumber: 13,
          partIndex: 1,
          totalParts: 2,
        ),
        const AyahTrackSegment(
          fileName: '013-2.mp3',
          verseNumber: 13,
          partIndex: 2,
          totalParts: 2,
        ),
        for (int i = 14; i <= 31; i++)
          AyahTrackSegment(
            fileName: '${i.toString().padLeft(3, '0')}.mp3',
            verseNumber: i,
          ),
        const AyahTrackSegment(
          fileName: '032-1.mp3',
          verseNumber: 32,
          partIndex: 1,
          totalParts: 2,
        ),
        const AyahTrackSegment(
          fileName: '032-2.mp3',
          verseNumber: 32,
          partIndex: 2,
          totalParts: 2,
        ),
        for (int i = 33; i <= 36; i++)
          AyahTrackSegment(
            fileName: '${i.toString().padLeft(3, '0')}.mp3',
            verseNumber: i,
          ),
      ];
    }

    if (surahNumber == 84) {
      return <AyahTrackSegment>[
        const AyahTrackSegment(fileName: '000.mp3', verseNumber: 0),
        for (int i = 1; i <= 5; i++)
          AyahTrackSegment(
            fileName: '${i.toString().padLeft(3, '0')}.mp3',
            verseNumber: i,
          ),
        const AyahTrackSegment(
          fileName: '006-1.mp3',
          verseNumber: 6,
          partIndex: 1,
          totalParts: 2,
        ),
        const AyahTrackSegment(
          fileName: '006-2.mp3',
          verseNumber: 6,
          partIndex: 2,
          totalParts: 2,
        ),
        for (int i = 7; i <= 25; i++)
          AyahTrackSegment(
            fileName: '${i.toString().padLeft(3, '0')}.mp3',
            verseNumber: i,
          ),
      ];
    }

    if (surahNumber == 85) {
      return <AyahTrackSegment>[
        const AyahTrackSegment(fileName: '000.mp3', verseNumber: 0),
        for (int i = 1; i <= 22; i++)
          AyahTrackSegment(
            fileName: '${i.toString().padLeft(3, '0')}.mp3',
            verseNumber: i,
          ),
      ];
    }

    if (surahNumber == 86) {
      return <AyahTrackSegment>[
        const AyahTrackSegment(fileName: '000.mp3', verseNumber: 0),
        for (int i = 1; i <= 17; i++)
          AyahTrackSegment(
            fileName: '${i.toString().padLeft(3, '0')}.mp3',
            verseNumber: i,
          ),
      ];
    }

    if (surahNumber == 87) {
      return <AyahTrackSegment>[
        const AyahTrackSegment(fileName: '000.mp3', verseNumber: 0),
        for (int i = 1; i <= 6; i++)
          AyahTrackSegment(
            fileName: '${i.toString().padLeft(3, '0')}.mp3',
            verseNumber: i,
          ),
        const AyahTrackSegment(
          fileName: '007-1.mp3',
          verseNumber: 7,
          partIndex: 1,
          totalParts: 2,
        ),
        const AyahTrackSegment(
          fileName: '007-2.mp3',
          verseNumber: 7,
          partIndex: 2,
          totalParts: 2,
        ),
        for (int i = 8; i <= 19; i++)
          AyahTrackSegment(
            fileName: '${i.toString().padLeft(3, '0')}.mp3',
            verseNumber: i,
          ),
      ];
    }

    if (surahNumber == 88) {
      return <AyahTrackSegment>[
        const AyahTrackSegment(fileName: '000.mp3', verseNumber: 0),
        for (int i = 1; i <= 26; i++)
          AyahTrackSegment(
            fileName: '${i.toString().padLeft(3, '0')}.mp3',
            verseNumber: i,
          ),
      ];
    }

    if (surahNumber == 89) {
      return <AyahTrackSegment>[
        const AyahTrackSegment(fileName: '000.mp3', verseNumber: 0),
        for (int i = 1; i <= 22; i++)
          AyahTrackSegment(
            fileName: '${i.toString().padLeft(3, '0')}.mp3',
            verseNumber: i,
          ),
        const AyahTrackSegment(
          fileName: '023-1.mp3',
          verseNumber: 23,
          partIndex: 1,
          totalParts: 2,
        ),
        const AyahTrackSegment(
          fileName: '023-2.mp3',
          verseNumber: 23,
          partIndex: 2,
          totalParts: 2,
        ),
        for (int i = 24; i <= 30; i++)
          AyahTrackSegment(
            fileName: '${i.toString().padLeft(3, '0')}.mp3',
            verseNumber: i,
          ),
      ];
    }

    if (surahNumber == 90) {
      return <AyahTrackSegment>[
        const AyahTrackSegment(fileName: '000.mp3', verseNumber: 0),
        for (int i = 1; i <= 16; i++)
          AyahTrackSegment(
            fileName: '${i.toString().padLeft(3, '0')}.mp3',
            verseNumber: i,
          ),
        const AyahTrackSegment(
          fileName: '017-1.mp3',
          verseNumber: 17,
          partIndex: 1,
          totalParts: 2,
        ),
        const AyahTrackSegment(
          fileName: '017-2.mp3',
          verseNumber: 17,
          partIndex: 2,
          totalParts: 2,
        ),
        const AyahTrackSegment(
          fileName: '018.mp3',
          verseNumber: 18,
        ),
        const AyahTrackSegment(
          fileName: '019-1.mp3',
          verseNumber: 19,
          partIndex: 1,
          totalParts: 2,
        ),
        const AyahTrackSegment(
          fileName: '019-2.mp3',
          verseNumber: 19,
          partIndex: 2,
          totalParts: 2,
        ),
        const AyahTrackSegment(
          fileName: '020.mp3',
          verseNumber: 20,
        ),
      ];
    }

    if (surahNumber == 92) {
      return <AyahTrackSegment>[
        const AyahTrackSegment(fileName: '000.mp3', verseNumber: 0),
        for (int i = 1; i <= 21; i++)
          AyahTrackSegment(
            fileName: '${i.toString().padLeft(3, '0')}.mp3',
            verseNumber: i,
          ),
      ];
    }

    if (surahNumber == 94) {
      return <AyahTrackSegment>[
        const AyahTrackSegment(fileName: '000.mp3', verseNumber: 0),
        for (int i = 1; i <= 8; i++)
          AyahTrackSegment(
            fileName: '${i.toString().padLeft(3, '0')}.mp3',
            verseNumber: i,
          ),
      ];
    }

    if (surahNumber == 95) {
      return <AyahTrackSegment>[
        const AyahTrackSegment(fileName: '000.mp3', verseNumber: 0),
        for (int i = 1; i <= 5; i++)
          AyahTrackSegment(
            fileName: '${i.toString().padLeft(3, '0')}.mp3',
            verseNumber: i,
          ),
        const AyahTrackSegment(
          fileName: '006-1.mp3',
          verseNumber: 6,
          partIndex: 1,
          totalParts: 2,
        ),
        const AyahTrackSegment(
          fileName: '006-2.mp3',
          verseNumber: 6,
          partIndex: 2,
          totalParts: 2,
        ),
        for (int i = 7; i <= 8; i++)
          AyahTrackSegment(
            fileName: '${i.toString().padLeft(3, '0')}.mp3',
            verseNumber: i,
          ),
      ];
    }

    if (surahNumber == 97) {
      return <AyahTrackSegment>[
        const AyahTrackSegment(fileName: '000.mp3', verseNumber: 0),
        for (int i = 1; i <= 3; i++)
          AyahTrackSegment(
            fileName: '${i.toString().padLeft(3, '0')}.mp3',
            verseNumber: i,
          ),
        const AyahTrackSegment(
          fileName: '004-1.mp3',
          verseNumber: 4,
          partIndex: 1,
          totalParts: 2,
        ),
        const AyahTrackSegment(
          fileName: '004-2.mp3',
          verseNumber: 4,
          partIndex: 2,
          totalParts: 2,
        ),
        const AyahTrackSegment(
          fileName: '005.mp3',
          verseNumber: 5,
        ),
      ];
    }

    if (surahNumber == 101) {
      return <AyahTrackSegment>[
        const AyahTrackSegment(fileName: '000.mp3', verseNumber: 0),
        for (int i = 1; i <= 11; i++)
          AyahTrackSegment(
            fileName: '${i.toString().padLeft(3, '0')}.mp3',
            verseNumber: i,
          ),
      ];
    }

    final count = ayahFileCounts[surahNumber] ?? 0;
    if (count == 0) return [];

    final segments = <AyahTrackSegment>[];
    if (surahNumber == 1) {
      for (int i = 1; i <= count; i++) {
        segments.add(AyahTrackSegment(
          fileName: '${i.toString().padLeft(3, '0')}.mp3',
          verseNumber: i,
          partIndex: 1,
          totalParts: 1,
        ));
      }
    } else {
      // Standard Juz Amma format: 000.mp3 is Basmala (verse 0), 001..N is verses 1..N
      segments.add(const AyahTrackSegment(fileName: '000.mp3', verseNumber: 0));
      for (int i = 1; i < count; i++) {
        segments.add(AyahTrackSegment(
          fileName: '${i.toString().padLeft(3, '0')}.mp3',
          verseNumber: i,
          partIndex: 1,
          totalParts: 1,
        ));
      }
    }
    return segments;
  }

  static int getAyahCount(int surahNumber) {
    if (_surahSegments.containsKey(surahNumber)) {
      return _surahSegments[surahNumber]!.length;
    }
    return ayahFileCounts[surahNumber] ?? 0;
  }

  static String ayahAssetPath(int surahNumber, int ayahNumber) {
    final segments = getSegments(surahNumber);
    if (ayahNumber >= 1 && ayahNumber <= segments.length) {
      final surahPadded = surahNumber.toString().padLeft(3, '0');
      return '$_basePath/surah_$surahPadded/${segments[ayahNumber - 1].fileName}';
    }
    final surahPadded = surahNumber.toString().padLeft(3, '0');
    final ayahPadded = ayahNumber.toString().padLeft(3, '0');
    return '$_basePath/surah_$surahPadded/$ayahPadded.mp3';
  }

  static List<AudioTrack> getAyahTracks(int surahNumber) {
    final surah = JuzAmmaData.getSurahByNumber(surahNumber);
    if (surah == null) return [];

    final segments = getSegments(surahNumber);
    if (segments.isEmpty) return [];

    final surahPadded = surahNumber.toString().padLeft(3, '0');
    final tracks = <AudioTrack>[];

    for (int i = 0; i < segments.length; i++) {
      final seg = segments[i];
      tracks.add(AudioTrack(
        id: '${surahNumber}_track_${(i + 1).toString().padLeft(3, '0')}',
        surahNumber: surahNumber,
        surahNameArabic: surah.nameArabic,
        surahNameEnglish: surah.nameEnglish,
        reciterName: AppConstants.reciterName,
        assetPath: '$_basePath/surah_$surahPadded/${seg.fileName}',
        pageNumber: surah.pageStart,
        trackType: 'ayah',
        ayahNumber: i + 1,
        verseNumber: seg.verseNumber,
        partIndex: seg.partIndex,
        totalParts: seg.totalParts,
      ));
    }
    return tracks;
  }
}

/// Represents a single audio file segment for a Quran ayah.
class AyahTrackSegment {
  final String fileName;
  final int verseNumber;
  final int partIndex;
  final int totalParts;

  const AyahTrackSegment({
    required this.fileName,
    required this.verseNumber,
    this.partIndex = 1,
    this.totalParts = 1,
  });

  bool get isMultiPart => totalParts > 1;

  @override
  String toString() =>
      'AyahTrackSegment(file: $fileName, verse: $verseNumber, part: $partIndex/$totalParts)';
}

class _RawFileInfo {
  final String fileName;
  final int base;
  final int part;

  const _RawFileInfo(this.fileName, this.base, this.part);
}
