enum HifzPhase { listening, reciting }

class MemorizationSettings {
  final int ayahRepeatCount;
  final bool pauseForRecitation;
  final bool repeatSurah;
  final double volume;
  final double playbackSpeed;

  const MemorizationSettings({
    this.ayahRepeatCount = 1,
    this.pauseForRecitation = false,
    this.repeatSurah = false,
    this.volume = 1.0,
    this.playbackSpeed = 1.0,
  });

  MemorizationSettings copyWith({
    int? ayahRepeatCount,
    bool? pauseForRecitation,
    bool? repeatSurah,
    double? volume,
    double? playbackSpeed,
  }) {
    return MemorizationSettings(
      ayahRepeatCount: ayahRepeatCount ?? this.ayahRepeatCount,
      pauseForRecitation: pauseForRecitation ?? this.pauseForRecitation,
      repeatSurah: repeatSurah ?? this.repeatSurah,
      volume: volume ?? this.volume,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
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
  final HifzPhase phase;
  final Duration? pauseRemaining;
  final Duration? pauseTotalDuration;

  const MemorizationPlaybackState({
    this.currentAyah = 0,
    this.currentRepetition = 0,
    this.currentAyahDuration = Duration.zero,
    this.totalAyahs = 0,
    this.isHifzActive = false,
    this.isPauseModeActive = false,
    this.phase = HifzPhase.listening,
    this.pauseRemaining,
    this.pauseTotalDuration,
  });

  MemorizationPlaybackState copyWith({
    int? currentAyah,
    int? currentRepetition,
    Duration? currentAyahDuration,
    int? totalAyahs,
    bool? isHifzActive,
    bool? isPauseModeActive,
    HifzPhase? phase,
    Duration? pauseRemaining,
    Duration? pauseTotalDuration,
  }) {
    return MemorizationPlaybackState(
      currentAyah: currentAyah ?? this.currentAyah,
      currentRepetition: currentRepetition ?? this.currentRepetition,
      currentAyahDuration: currentAyahDuration ?? this.currentAyahDuration,
      totalAyahs: totalAyahs ?? this.totalAyahs,
      isHifzActive: isHifzActive ?? this.isHifzActive,
      isPauseModeActive: isPauseModeActive ?? this.isPauseModeActive,
      phase: phase ?? this.phase,
      pauseRemaining: pauseRemaining ?? this.pauseRemaining,
      pauseTotalDuration: pauseTotalDuration ?? this.pauseTotalDuration,
    );
  }

  double get pauseProgress {
    if (pauseRemaining == null || pauseTotalDuration == null || pauseTotalDuration!.inMilliseconds <= 0) return 0.0;
    return 1.0 - (pauseRemaining!.inMilliseconds / pauseTotalDuration!.inMilliseconds);
  }

  double get ayahProgress {
    if (totalAyahs <= 0) return 0.0;
    return (currentAyah - 1) / totalAyahs;
  }
}
