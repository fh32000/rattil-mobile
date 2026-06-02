import 'package:flutter/material.dart';
import '../../../../data/models/memorization_settings.dart';
import '../../../../core/utils/duration_helpers.dart';

class PauseCountdownBar extends StatelessWidget {
  final MemorizationPlaybackState state;

  const PauseCountdownBar({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.phase != HifzPhase.reciting) return const SizedBox.shrink();

    final progress = state.pauseProgress;
    final remaining = state.pauseRemaining ?? Duration.zero;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.timer_outlined, color: Colors.orange.shade300, size: 18),
              const SizedBox(width: 8),
              Text(
                'ردد الآية الآن',
                style: TextStyle(
                  color: Colors.orange.shade200,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                formatDuration(remaining),
                style: TextStyle(
                  color: Colors.orange.shade100,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(Colors.orange.shade300),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}
