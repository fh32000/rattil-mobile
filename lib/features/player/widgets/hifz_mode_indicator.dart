import 'package:flutter/material.dart';
import '../../../../data/models/memorization_settings.dart';
import '../../../../core/theme/app_colors.dart';

class HifzModeIndicator extends StatefulWidget {
  final MemorizationPlaybackState state;

  const HifzModeIndicator({super.key, required this.state});

  @override
  State<HifzModeIndicator> createState() => _HifzModeIndicatorState();
}

class _HifzModeIndicatorState extends State<HifzModeIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isReciting = widget.state.phase == HifzPhase.reciting;

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final t = _anim.value;
        final opacity = 0.5 + t * 0.5;
        final scale = 1.0 + t * 0.08;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isReciting
                ? Colors.orange.withValues(alpha: 0.15 * opacity)
                : const Color(0xFF4CAF50).withValues(alpha: 0.15 * opacity),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isReciting
                  ? Colors.orange.withValues(alpha: 0.4 * opacity)
                  : const Color(0xFF4CAF50).withValues(alpha: 0.4 * opacity),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.scale(
                scale: scale,
                child: Icon(
                  isReciting ? Icons.record_voice_over : Icons.hearing,
                  color: isReciting
                      ? Colors.orange.withValues(alpha: opacity)
                      : const Color(0xFF4CAF50).withValues(alpha: opacity),
                  size: 24,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                isReciting ? 'ردد الآية الآن' : 'استمع للآية',
                style: TextStyle(
                  color: isReciting
                      ? Colors.orange.withValues(alpha: opacity)
                      : const Color(0xFF4CAF50).withValues(alpha: opacity),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
