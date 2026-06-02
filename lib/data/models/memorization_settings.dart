class MemorizationSettings {
  final int ayahRepeatCount;
  final bool pauseForRecitation;
  final bool repeatSurah;

  const MemorizationSettings({
    this.ayahRepeatCount = 1,
    this.pauseForRecitation = false,
    this.repeatSurah = false,
  });

  MemorizationSettings copyWith({
    int? ayahRepeatCount,
    bool? pauseForRecitation,
    bool? repeatSurah,
  }) {
    return MemorizationSettings(
      ayahRepeatCount: ayahRepeatCount ?? this.ayahRepeatCount,
      pauseForRecitation: pauseForRecitation ?? this.pauseForRecitation,
      repeatSurah: repeatSurah ?? this.repeatSurah,
    );
  }
}

class MemorizationPlaybackState {
  final int currentAyah;
  final int currentRepetition;
  final Duration currentAyahDuration;
  final int totalAyahs;
  final bool isHifzActive;
  final bool isPauseModeActive;

  const MemorizationPlaybackState({
    this.currentAyah = 0,
    this.currentRepetition = 0,
    this.currentAyahDuration = Duration.zero,
    this.totalAyahs = 0,
    this.isHifzActive = false,
    this.isPauseModeActive = false,
  });

  MemorizationPlaybackState copyWith({
    int? currentAyah,
    int? currentRepetition,
    Duration? currentAyahDuration,
    int? totalAyahs,
    bool? isHifzActive,
    bool? isPauseModeActive,
  }) {
    return MemorizationPlaybackState(
      currentAyah: currentAyah ?? this.currentAyah,
      currentRepetition: currentRepetition ?? this.currentRepetition,
      currentAyahDuration: currentAyahDuration ?? this.currentAyahDuration,
      totalAyahs: totalAyahs ?? this.totalAyahs,
      isHifzActive: isHifzActive ?? this.isHifzActive,
      isPauseModeActive: isPauseModeActive ?? this.isPauseModeActive,
    );
  }
}
