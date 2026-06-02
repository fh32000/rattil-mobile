import 'package:flutter/material.dart';
import '../../../../data/models/memorization_settings.dart';
import '../../../../core/theme/app_colors.dart';

class HifzProgressBar extends StatelessWidget {
  final MemorizationPlaybackState state;

  const HifzProgressBar({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final progress = state.ayahProgress;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            valueColor: const AlwaysStoppedAnimation(Color(0xFF4CAF50)),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'آية ${state.currentAyah} من ${state.totalAyahs}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
