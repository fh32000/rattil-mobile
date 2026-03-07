import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/duration_helpers.dart';
import '../providers/audio_provider.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackAsync = ref.watch(currentTrackProvider);
    final isPlayingAsync = ref.watch(isPlayingProvider);
    final positionAsync = ref.watch(positionProvider);
    final durationAsync = ref.watch(durationProvider);
    final handler = ref.watch(audioHandlerProvider);

    return trackAsync.when(
      data: (track) {
        if (track == null) return const SizedBox.shrink();

        final isPlaying = isPlayingAsync.valueOrNull ?? false;
        final position = positionAsync.valueOrNull ?? Duration.zero;
        final duration = durationAsync.valueOrNull ?? Duration.zero;
        final totalMs = duration.inMilliseconds.toDouble();
        final posMs = position.inMilliseconds.toDouble();
        final progress = totalMs > 0 ? posMs / totalMs : 0.0;

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
                  // Progress indicator
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation(AppColors.accent),
                      minHeight: 3,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
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
                                'سورة ${track.surahNameArabic}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${track.reciterName}  ·  ${formatDuration(position)}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),

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
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accent,
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
                          icon: const Icon(
                            Icons.skip_previous_rounded,
                            size: 26,
                          ),
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
}
