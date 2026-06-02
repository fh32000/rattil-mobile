import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../services/audio_handler.dart';

class VolumeControl extends StatelessWidget {
  final QuranAudioHandler handler;
  final double currentVolume;

  const VolumeControl({
    super.key,
    required this.handler,
    required this.currentVolume,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          currentVolume <= 0
              ? Icons.volume_mute
              : currentVolume < 0.5
                  ? Icons.volume_down
                  : Icons.volume_up,
          color: Colors.white60,
          size: 18,
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
              activeTrackColor: const Color(0xFF4CAF50),
              inactiveTrackColor: Colors.white.withValues(alpha: 0.15),
              thumbColor: const Color(0xFF4CAF50),
              overlayColor: const Color(0xFF4CAF50).withValues(alpha: 0.2),
            ),
            child: Slider(
              min: 0.0,
              max: 1.0,
              value: currentVolume.clamp(0.0, 1.0),
              onChanged: (v) => handler.setVolume(v),
            ),
          ),
        ),
        Icon(
          Icons.volume_up,
          color: Colors.white60,
          size: 18,
        ),
      ],
    );
  }
}
