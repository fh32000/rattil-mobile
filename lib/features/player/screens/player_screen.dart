import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/duration_helpers.dart';
import '../../../data/models/audio_track.dart';
import '../providers/audio_provider.dart';
import '../services/audio_handler.dart';

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackAsync = ref.watch(currentTrackProvider);
    final isPlayingAsync = ref.watch(isPlayingProvider);
    final positionAsync = ref.watch(positionProvider);
    final durationAsync = ref.watch(durationProvider);
    final loopModeAsync = ref.watch(loopModeProvider);
    final favorites = ref.watch(favoritesProvider);
    final handler = ref.watch(audioHandlerProvider);

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

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryDark,
                  AppColors.backgroundDark,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Top bar
                  _buildTopBar(context),

                  const Spacer(flex: 1),

                  // Surah artwork/decoration
                  _buildSurahArt(track),

                  const Spacer(flex: 1),

                  // Track info
                  _buildTrackInfo(track),

                  const SizedBox(height: 32),

                  // Progress bar
                  _buildProgressBar(
                    context,
                    handler,
                    position,
                    duration,
                  ),

                  const SizedBox(height: 24),

                  // Controls
                  _buildControls(
                    handler,
                    isPlaying,
                    loopMode,
                    isFav,
                    track,
                    ref,
                  ),

                  const Spacer(flex: 2),
                ],
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
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(width: 48), // Balance
        ],
      ),
    );
  }

  Widget _buildSurahArt(AudioTrack track) {
    return Container(
      width: 240,
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'سورة',
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
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'صفحة ${track.pageNumber}',
              style: TextStyle(
                color: AppColors.accentLight,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackInfo(AudioTrack track) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Text(
            'سورة ${track.surahNameArabic}',
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
            style: TextStyle(
              color: AppColors.accentLight,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
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

  Widget _buildControls(
    QuranAudioHandler handler,
    bool isPlaying,
    LoopMode loopMode,
    bool isFav,
    AudioTrack track,
    WidgetRef ref,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Loop
          IconButton(
            icon: Icon(
              loopMode == LoopMode.one
                  ? Icons.repeat_one
                  : Icons.repeat,
              color: loopMode == LoopMode.off
                  ? Colors.white60
                  : AppColors.accent,
            ),
            iconSize: 28,
            onPressed: () => handler.cycleLoopMode(),
          ),

          // Previous
          IconButton(
            icon: const Icon(Icons.skip_previous_rounded),
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
              gradient: const LinearGradient(
                colors: [AppColors.accent, AppColors.accentLight],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
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
            icon: const Icon(Icons.skip_next_rounded),
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
