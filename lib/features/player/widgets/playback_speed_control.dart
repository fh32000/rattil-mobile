import 'package:flutter/material.dart';
import '../services/audio_handler.dart';

class PlaybackSpeedControl extends StatelessWidget {
  final QuranAudioHandler handler;
  final double currentSpeed;

  const PlaybackSpeedControl({
    super.key,
    required this.handler,
    required this.currentSpeed,
  });

  static const List<double> speedOptions = [
    0.5,
    0.75,
    1.0,
    1.25,
    1.5,
    1.75,
    2.0,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(Icons.speed, color: Colors.white60, size: 18),
            const SizedBox(width: 8),
            Text(
              'سرعة التشغيل',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: speedOptions.map((speed) {
            final isSelected = speed == currentSpeed;
            return GestureDetector(
              onTap: () => handler.setPlaybackSpeed(speed),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF4CAF50).withValues(alpha: 0.25)
                      : Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(
                          color: const Color(0xFF4CAF50).withValues(alpha: 0.5),
                        )
                      : null,
                ),
                child: Text(
                  '${speed}x',
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF4CAF50) : Colors.white70,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
