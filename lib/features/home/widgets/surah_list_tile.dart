import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/surah.dart';

class SurahListTile extends StatelessWidget {
  final Surah surah;
  final VoidCallback onTap;
  final VoidCallback onPlay;
  final bool isCurrentTrack;
  final bool isPlaying;

  const SurahListTile({
    super.key,
    required this.surah,
    required this.onTap,
    required this.onPlay,
    this.isCurrentTrack = false,
    this.isPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: isCurrentTrack
                  ? AppColors.accent.withValues(alpha: 0.08)
                  : null,
              border: isCurrentTrack
                  ? Border.all(color: AppColors.accent.withValues(alpha: 0.2))
                  : null,
            ),
            child: Row(
              children: [
                // Surah number
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isCurrentTrack
                        ? AppColors.accent.withValues(alpha: 0.2)
                        : AppColors.primary.withValues(alpha: 0.15),
                  ),
                  child: Center(
                    child: Text(
                      surah.number.toString(),
                      style: TextStyle(
                        color: isCurrentTrack
                            ? AppColors.accent
                            : AppColors.primaryLight,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // Surah info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'سورة ${surah.nameArabic}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isCurrentTrack ? AppColors.accent : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          _buildChip(surah.revelationType),
                          const SizedBox(width: 8),
                          Text(
                            '${surah.versesCount} آية',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'ص ${surah.pageStart}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Play/Pause button
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCurrentTrack && isPlaying
                        ? AppColors.accent
                        : AppColors.accent.withValues(alpha: 0.15),
                  ),
                  child: IconButton(
                    icon: Icon(
                      isCurrentTrack && isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 22,
                    ),
                    color: isCurrentTrack && isPlaying
                        ? Colors.black
                        : AppColors.accent,
                    padding: EdgeInsets.zero,
                    onPressed: onPlay,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.accent,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
