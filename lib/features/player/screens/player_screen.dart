import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/duration_helpers.dart';
import '../../../data/models/audio_track.dart';
import '../../../data/models/memorization_settings.dart';
import '../providers/audio_provider.dart';
import '../services/audio_handler.dart';
import '../widgets/hifz_progress_bar.dart';
import '../widgets/pause_countdown_bar.dart';
import '../widgets/volume_control.dart';
import '../widgets/playback_speed_control.dart';
import '../widgets/verse_display_widget.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  bool _showMemControls = false;

  @override
  Widget build(BuildContext context) {
    final trackAsync = ref.watch(currentTrackProvider);
    final isPlayingAsync = ref.watch(isPlayingProvider);
    final positionAsync = ref.watch(positionProvider);
    final durationAsync = ref.watch(durationProvider);
    final loopModeAsync = ref.watch(loopModeProvider);
    final favorites = ref.watch(favoritesProvider);
    final handler = ref.watch(audioHandlerProvider);
    final canHifz = ref.watch(canEnableHifzModeProvider);
    final isHifz = ref.watch(isHifzModeActiveProvider);
    final memSettingsAsync = ref.watch(memorizationSettingsProvider);
    final memStateAsync = ref.watch(memorizationPlaybackStateProvider);

    return Scaffold(
      body: trackAsync.when(
        data: (track) {
          if (track == null) {
            return const Center(
              child: Text(
                'لا يوجد مقطع قيد التشغيل',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final isPlaying = isPlayingAsync.valueOrNull ?? false;
          final position = positionAsync.valueOrNull ?? Duration.zero;
          final duration = durationAsync.valueOrNull ?? Duration.zero;
          final loopMode = loopModeAsync.valueOrNull ?? LoopMode.off;
          final isFav = favorites.contains(track.id);
          final memSettings = memSettingsAsync.valueOrNull ??
              const MemorizationSettings();
          final memState = memStateAsync.valueOrNull ??
              const MemorizationPlaybackState();

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.primaryDark, AppColors.backgroundDark],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 16,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Top bar
                      _buildTopBar(context),

                      if (isHifz) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                          child: VerseDisplayWidget(
                            surahNumber: track.surahNumber,
                            currentAudioIndex: memState.currentAyah,
                            totalAudioFiles: memState.totalAyahs,
                            phase: memState.phase,
                          ),
                        ),
                      ] else ...[
                        // Surah artwork/decoration (non-Hifz only)
                        _buildSurahArt(track, isHifz, memState),
                      ],

                      const SizedBox(height: 24),

                      // Track info
                      _buildTrackInfo(context, track, isHifz, memState),

                      const SizedBox(height: 16),

                      if (isHifz) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: memState.phase == HifzPhase.reciting
                              ? PauseCountdownBar(state: memState)
                              : HifzProgressBar(state: memState),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Progress bar
                      _buildProgressBar(context, handler, position, duration),

                      // Memorization controls
                      if (canHifz && !isHifz) ...[
                        const SizedBox(height: 8),
                        _buildMemorizationToggle(handler, isHifz),
                      ],
                      if (isHifz) ...[
                        const SizedBox(height: 6),
                        _buildMemorizationToggle(handler, isHifz),
                        const SizedBox(height: 6),
                        _buildMemorizationControls(handler, memSettings),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                VolumeControl(
                                  handler: handler,
                                  currentVolume: memSettings.volume,
                                ),
                                const Divider(height: 4, color: Colors.white10),
                                PlaybackSpeedControl(
                                  handler: handler,
                                  currentSpeed: memSettings.playbackSpeed,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 12),

                      // Controls
                      _buildControls(
                        handler,
                        isPlaying,
                        loopMode,
                        isFav,
                        track,
                        ref,
                        isHifz,
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down, size: 32),
            color: Colors.white,
            onPressed: () => Navigator.of(context).pop(),
          ),
          Text(
            'جزء عمّ',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(width: 48), // Balance
        ],
      ),
    );
  }

  Widget _buildSurahArt(
    AudioTrack track,
    bool isHifz,
    MemorizationPlaybackState memState,
  ) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: isHifz
              ? [const Color(0xFF1B5E20), const Color(0xFF0D3D12)]
              : [AppColors.primary, AppColors.primaryDark],
        ),
        boxShadow: [
          BoxShadow(
            color: (isHifz ? const Color(0xFF1B5E20) : AppColors.primary)
                .withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (track.isSurah && !isHifz)
            Text(
              'سورة',
              style: TextStyle(
                color: AppColors.accentLight,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          if (isHifz) ...[
            Text(
              'آية',
              style: TextStyle(
                color: AppColors.accentLight,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${memState.currentAyah}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'من ${memState.totalAyahs}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
          ] else ...[
            if (!track.isSurah)
              Text(
                'حرف',
                style: TextStyle(
                  color: AppColors.accentLight,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              track.surahNameArabic,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                fontFamily: 'Amiri',
              ),
            ),
          ],
          if (track.isSurah && !isHifz) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'صفحة ${track.pageNumber}',
                style: TextStyle(color: AppColors.accentLight, fontSize: 13),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTrackInfo(
    BuildContext context,
    AudioTrack track,
    bool isHifz,
    MemorizationPlaybackState memState,
  ) {
    final memSettingsAsync = ref.watch(memorizationSettingsProvider);
    final memSettings = memSettingsAsync.valueOrNull ??
        const MemorizationSettings();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Text(
            track.isAyah ? 'سورة ${track.surahNameArabic}' : track.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            track.reciterName,
            style: TextStyle(color: AppColors.accentLight, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          if (isHifz && memState.totalAyahs > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'التكرار ${memState.currentRepetition + 1}/${memSettings.ayahRepeatCount}',
                style: TextStyle(color: AppColors.accentLight, fontSize: 13),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressBar(
    BuildContext context,
    QuranAudioHandler handler,
    Duration position,
    Duration duration,
  ) {
    final totalMs = duration.inMilliseconds.toDouble();
    final posMs = position.inMilliseconds.toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: AppColors.accent,
              inactiveTrackColor: AppColors.progressInactive,
              thumbColor: AppColors.accent,
              overlayColor: AppColors.accent.withValues(alpha: 0.2),
            ),
            child: Slider(
              min: 0,
              max: totalMs > 0 ? totalMs : 1,
              value: posMs.clamp(0, totalMs > 0 ? totalMs : 1),
              onChanged: (value) {
                handler.seek(Duration(milliseconds: value.toInt()));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatDuration(position),
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                ),
                Text(
                  formatDuration(duration),
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemorizationToggle(QuranAudioHandler handler, bool isHifz) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: GestureDetector(
        onTap: () {
          if (isHifz) {
            handler.disableHifzMode();
          } else {
            handler.enableHifzMode();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isHifz
                ? const Color(0xFF1B5E20).withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isHifz
                  ? const Color(0xFF4CAF50).withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isHifz ? Icons.auto_stories : Icons.menu_book,
                    color: isHifz
                        ? const Color(0xFF4CAF50)
                        : Colors.white70,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isHifz ? 'وضع الحفظ (مفعل)' : 'وضع الحفظ',
                    style: TextStyle(
                      color: isHifz ? const Color(0xFF4CAF50) : Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Switch(
                value: isHifz,
                onChanged: (_) {
                  if (isHifz) {
                    handler.disableHifzMode();
                  } else {
                    handler.enableHifzMode();
                  }
                },
                activeColor: const Color(0xFF4CAF50),
                activeTrackColor: const Color(0xFF4CAF50).withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemorizationControls(
    QuranAudioHandler handler,
    MemorizationSettings memSettings,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Ayah Repeat Count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'تكرار الآية',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                GestureDetector(
                  onTap: () => _showRepeatCountSheet(context, handler, memSettings),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${memSettings.ayahRepeatCount}x',
                          style: TextStyle(
                            color: AppColors.accentLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.accentLight,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Pause For Recitation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'انتظار بعد الآية',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      Text(
                        'انتظار لمدة الآية قبل المتابعة',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: memSettings.pauseForRecitation,
                  onChanged: (value) {
                    handler.updateMemorizationSettings(
                      memSettings.copyWith(pauseForRecitation: value),
                    );
                  },
                  activeColor: AppColors.accent,
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Repeat Surah
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'تكرار السورة',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Switch(
                  value: memSettings.repeatSurah,
                  onChanged: (value) {
                    handler.updateMemorizationSettings(
                      memSettings.copyWith(repeatSurah: value),
                    );
                  },
                  activeColor: AppColors.accent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRepeatCountSheet(
    BuildContext context,
    QuranAudioHandler handler,
    MemorizationSettings currentSettings,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'عدد مرات تكرار الآية',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ..._repeatOptions.map((count) {
                  final isSelected = currentSettings.ayahRepeatCount == count;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: () {
                        handler.updateMemorizationSettings(
                          currentSettings.copyWith(ayahRepeatCount: count),
                        );
                        Navigator.pop(sheetContext);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accent.withValues(alpha: 0.2)
                              : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(
                                  color: AppColors.accent.withValues(alpha: 0.5),
                                )
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${count}x',
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.accentLight
                                    : Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check,
                                color: AppColors.accentLight,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  static const List<int> _repeatOptions = [1, 2, 3, 5, 10];

  Widget _buildControls(
    QuranAudioHandler handler,
    bool isPlaying,
    LoopMode loopMode,
    bool isFav,
    AudioTrack track,
    WidgetRef ref,
    bool isHifz,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Loop (hide in hifz mode, as repeat surah replaces it)
          if (!isHifz)
            IconButton(
              icon: Icon(
                loopMode == LoopMode.one ? Icons.repeat_one : Icons.repeat,
                color: loopMode == LoopMode.off
                    ? Colors.white60
                    : AppColors.accent,
              ),
              iconSize: 28,
              onPressed: () => handler.cycleLoopMode(),
            ),

          // Previous
          IconButton(
            icon: Icon(
              isHifz ? Icons.skip_previous_rounded : Icons.skip_next_rounded,
            ),
            color: Colors.white,
            iconSize: 40,
            onPressed: () => handler.skipToPrevious(),
          ),

          // Rewind 10s
          IconButton(
            icon: const Icon(Icons.replay_10_rounded),
            color: Colors.white,
            iconSize: 32,
            onPressed: () => handler.rewind10(),
          ),

          // Play/Pause
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: isHifz
                    ? [const Color(0xFF4CAF50), const Color(0xFF81C784)]
                    : [AppColors.accent, AppColors.accentLight],
              ),
              boxShadow: [
                BoxShadow(
                  color: (isHifz
                          ? const Color(0xFF4CAF50)
                          : AppColors.accent)
                      .withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              ),
              color: Colors.black,
              iconSize: 44,
              onPressed: () {
                if (isPlaying) {
                  handler.pause();
                } else {
                  handler.play();
                }
              },
            ),
          ),

          // Forward 10s
          IconButton(
            icon: const Icon(Icons.forward_10_rounded),
            color: Colors.white,
            iconSize: 32,
            onPressed: () => handler.fastForward10(),
          ),

          // Next
          IconButton(
            icon: Icon(
              isHifz ? Icons.skip_next_rounded : Icons.skip_previous_rounded,
            ),
            color: Colors.white,
            iconSize: 40,
            onPressed: () => handler.skipToNext(),
          ),

          // Favorite
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? AppColors.error : Colors.white60,
            ),
            iconSize: 28,
            onPressed: () {
              ref.read(favoritesProvider.notifier).toggle(track.id);
            },
          ),
        ],
      ),
    );
  }
}
