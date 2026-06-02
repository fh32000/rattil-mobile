enum HifzPhase { listening, reciting }

class MemorizationSettings {
  final int ayahRepeatCount;
  final bool pauseForRecitation;
  final bool repeatSurah;
  final double volume;
  final double playbackSpeed;
  final double recitationMultiplier;
  final bool hideVerses;

  const MemorizationSettings({
    this.ayahRepeatCount = 3,
    this.pauseForRecitation = true,
    this.repeatSurah = false,
    this.volume = 1.0,
    this.playbackSpeed = 1.0,
    this.recitationMultiplier = 1.0,
    this.hideVerses = false,
  });

  MemorizationSettings copyWith({
    int? ayahRepeatCount,
    bool? pauseForRecitation,
    bool? repeatSurah,
    double? volume,
    double? playbackSpeed,
    double? recitationMultiplier,
    bool? hideVerses,
  }) {
    return MemorizationSettings(
      ayahRepeatCount: ayahRepeatCount ?? this.ayahRepeatCount,
      pauseForRecitation: pauseForRecitation ?? this.pauseForRecitation,
      repeatSurah: repeatSurah ?? this.repeatSurah,
      volume: volume ?? this.volume,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      recitationMultiplier: recitationMultiplier ?? this.recitationMultiplier,
      hideVerses: hideVerses ?? this.hideVerses,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ayahRepeatCount': ayahRepeatCount,
      'pauseForRecitation': pauseForRecitation,
      'repeatSurah': repeatSurah,
      'volume': volume,
      'playbackSpeed': playbackSpeed,
      'recitationMultiplier': recitationMultiplier,
      'hideVerses': hideVerses,
    };
  }

  factory MemorizationSettings.fromMap(Map<String, dynamic> map) {
    return MemorizationSettings(
      ayahRepeatCount: map['ayahRepeatCount'] as int? ?? 3,
      pauseForRecitation: map['pauseForRecitation'] as bool? ?? true,
      repeatSurah: map['repeatSurah'] as bool? ?? false,
      volume: (map['volume'] as num?)?.toDouble() ?? 1.0,
      playbackSpeed: (map['playbackSpeed'] as num?)?.toDouble() ?? 1.0,
      recitationMultiplier: (map['recitationMultiplier'] as num?)?.toDouble() ?? 1.0,
      hideVerses: map['hideVerses'] as bool? ?? false,
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
