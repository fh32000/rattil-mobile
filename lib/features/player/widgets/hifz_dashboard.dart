import 'package:flutter/material.dart';
import '../../../../data/models/audio_track.dart';
import '../../../../data/models/memorization_settings.dart';

class HifzDashboard extends StatelessWidget {
  final AudioTrack track;
  final MemorizationPlaybackState state;
  final MemorizationSettings settings;

  const HifzDashboard({
    super.key,
    required this.track,
    required this.state,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    if (!state.isHifzActive) return const SizedBox.shrink();

    final isReciting = state.phase == HifzPhase.reciting;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row('السورة', track.surahNameArabic),
          const SizedBox(height: 6),
          _row('الآية', '${state.currentAyah} من ${state.totalAyahs}'),
          const SizedBox(height: 6),
          _row('التكرار', '${state.currentRepetition + 1}/${settings.ayahRepeatCount}'),
          const SizedBox(height: 6),
          _row('السرعة', '${settings.playbackSpeed}x'),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                'الوضع الحالي: ',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
              Icon(
                isReciting ? Icons.record_voice_over : Icons.hearing,
                size: 16,
                color: isReciting ? Colors.orange : const Color(0xFF4CAF50),
              ),
              const SizedBox(width: 4),
              Text(
                isReciting ? 'ترديد' : 'استماع',
                style: TextStyle(
                  color: isReciting ? Colors.orange : const Color(0xFF4CAF50),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
