import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/arabic_letter.dart';

class LetterCard extends StatelessWidget {
  final ArabicLetter letter;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onPlay;

  const LetterCard({
    super.key,
    required this.letter,
    required this.isPlaying,
    required this.onTap,
    required this.onPlay,
  });

  Color get _groupColor {
    switch (letter.makhrajGroup) {
      case 'الحلق':
        return const Color(0xFF1565C0); // أزرق داكن
      case 'اللسان':
        return AppColors.primary;
      case 'الشفتان':
        return const Color(0xFF6A1B9A); // بنفسجي
      default:
        return AppColors.primaryDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _groupColor;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              color.withValues(alpha: isPlaying ? 0.5 : 0.15),
              color.withValues(alpha: isPlaying ? 0.3 : 0.05),
            ],
          ),
          border: Border.all(
            color: isPlaying
                ? AppColors.accent
                : color.withValues(alpha: 0.2),
            width: isPlaying ? 1.5 : 1,
          ),
          boxShadow: isPlaying
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
        child: Stack(
          children: [
            // Subtle number in corner
            Positioned(
              top: 6,
              left: 8,
              child: Text(
                letter.number.toString(),
                style: TextStyle(
                  fontSize: 10,
                  color: color.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Main content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Arabic letter — big
                Text(
                  letter.arabicLetter,
                  style: TextStyle(
                    fontSize: 36,
                    color: isPlaying ? AppColors.accentLight : Colors.white,
                    fontFamily: 'Amiri',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                // Letter name
                Text(
                  letter.name,
                  style: TextStyle(
                    fontSize: 10,
                    color: isPlaying
                        ? AppColors.accentLight
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                // Play button
                GestureDetector(
                  onTap: onPlay,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isPlaying
                          ? AppColors.accent
                          : color.withValues(alpha: 0.25),
                    ),
                    child: Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: isPlaying ? Colors.black : Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
