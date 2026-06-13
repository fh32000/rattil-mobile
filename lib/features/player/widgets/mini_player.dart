import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/duration_helpers.dart';
import '../../../data/models/memorization_settings.dart';
import '../providers/audio_provider.dart';
import '../widgets/playback_speed_control.dart';
import 'hifz_progress_bar.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackAsync = ref.watch(currentTrackProvider);
    final isPlayingAsync = ref.watch(isPlayingProvider);
    final positionAsync = ref.watch(positionProvider);
    final durationAsync = ref.watch(durationProvider);
    final handler = ref.watch(audioHandlerProvider);
    final isHifz = ref.watch(isHifzModeActiveProvider);
    final memStateAsync = ref.watch(memorizationPlaybackStateProvider);
    final memSettingsAsync = ref.watch(memorizationSettingsProvider);

    return trackAsync.when(
      data: (track) {
        if (track == null) return const SizedBox.shrink();

        final isPlaying = isPlayingAsync.valueOrNull ?? false;
        final position = positionAsync.valueOrNull ?? Duration.zero;
        final duration = durationAsync.valueOrNull ?? Duration.zero;
        final totalMs = duration.inMilliseconds.toDouble();
        final posMs = position.inMilliseconds.toDouble();
        final progress = totalMs > 0 ? posMs / totalMs : 0.0;
        final memState = memStateAsync.valueOrNull ??
            const MemorizationPlaybackState();
        final memSettings = memSettingsAsync.valueOrNull ??
            const MemorizationSettings();
        final currentSpeed = memSettings.playbackSpeed;

        return GestureDetector(
          onTap: () => context.push('/player'),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom,
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Playback progress
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation(
                        isHifz ? const Color(0xFF4CAF50) : AppColors.accent,
                      ),
                      minHeight: 3,
                    ),
                  ),

                  // Hifz ayah progress
                  if (isHifz && memState.totalAyahs > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: HifzProgressBar(state: memState),
                    ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        // Surah icon
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primaryDark,
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              track.surahNumber.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Track info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                track.isAyah
                                    ? 'سورة ${track.surahNameArabic}'
                                    : track.displayName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                isHifz && memState.totalAyahs > 0
                                    ? 'آية ${memState.currentAyah} من ${memState.totalAyahs}  ·  ${formatDuration(position)}  ${memState.phase == HifzPhase.reciting ? '🔊' : '👂'}'
                                    : '${track.reciterName}  ·  ${formatDuration(position)}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),

                        // Speed indicator
                        GestureDetector(
                          onTap: () => _showSpeedSheet(context, handler, currentSpeed),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${currentSpeed}x',
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 4),

                        // Skip previous
                        IconButton(
                          icon: const Icon(Icons.skip_next_rounded, size: 26),
                          color: Colors.white70,
                          onPressed: () => handler.skipToPrevious(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                        ),

                        // Play/Pause
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isHifz
                                ? const Color(0xFF4CAF50)
                                : AppColors.accent,
                          ),
                          child: IconButton(
                            icon: Icon(
                              isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              size: 24,
                            ),
                            color: Colors.black,
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              if (isPlaying) {
                                handler.pause();
                              } else {
                                handler.play();
                              }
                            },
                          ),
                        ),

                        // Skip next
                        IconButton(
                          icon: const Icon(Icons.skip_previous_rounded, size: 26),
                          color: Colors.white70,
                          onPressed: () => handler.skipToNext(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  void _showSpeedSheet(
    BuildContext context,
    dynamic handler,
    double currentSpeed,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'سرعة التشغيل',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: PlaybackSpeedControl.speedOptions.map((speed) {
                    final isSelected = speed == currentSpeed;
                    return GestureDetector(
                      onTap: () {
                        handler.setPlaybackSpeed(speed);
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accent.withValues(alpha: 0.25)
                              : Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(
                                  color: AppColors.accent.withValues(alpha: 0.5),
                                )
                              : null,
                        ),
                        child: Text(
                          '${speed}x',
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.accent
                                : Colors.white70,
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}
