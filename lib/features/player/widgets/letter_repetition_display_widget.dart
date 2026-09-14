import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/arabic_letter.dart';
import '../../../data/models/audio_track.dart';
import '../../../data/models/memorization_settings.dart';
import '../../../data/sources/arabic_alphabet_data.dart';

/// Displays the current Arabic letter and its active diacritic movement
/// for the letter repetition mode in the full player screen.
class LetterRepetitionDisplayWidget extends StatelessWidget {
  final AudioTrack track;
  final int currentSegment; // 1-based index (1..5)
  final int totalSegments;
  final HifzPhase phase;
  final bool hideVerses;
  final ValueChanged<int>? onSegmentSelected;

  const LetterRepetitionDisplayWidget({
    super.key,
    required this.track,
    required this.currentSegment,
    required this.totalSegments,
    required this.phase,
    this.hideVerses = false,
    this.onSegmentSelected,
  });

  static int? resolveLetterNumber(AudioTrack track) {
    if (track.id.startsWith('letter_')) {
      final parts = track.id.split('_');
      if (parts.length >= 2) {
        return int.tryParse(parts[1]);
      }
    }
    if (track.surahNumber > 0 && track.surahNumber <= 28) {
      return track.surahNumber;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final letterNumber = resolveLetterNumber(track);
    final letter = letterNumber != null
        ? ArabicAlphabetData.getByNumber(letterNumber)
        : null;

    final isReciting = phase == HifzPhase.reciting;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFF1B5E20),
              Color(0xFF0D3D12),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B5E20).withValues(alpha: 0.4),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildModeHeader(isReciting),
            const SizedBox(height: 14),
            if (hideVerses) ...[
              _buildHiddenPlaceholder(isReciting),
            ] else if (letter != null) ...[
              _buildLetterContent(letter),
            ] else ...[
              _buildFallbackContent(),
            ],
            const SizedBox(height: 14),
            _buildFooter(letter),
          ],
        ),
      ),
    );
  }

  Widget _buildModeHeader(bool isReciting) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          isReciting ? Icons.record_voice_over : Icons.hearing,
          size: 20,
          color: isReciting ? Colors.orange : const Color(0xFF81C784),
        ),
        const SizedBox(width: 8),
        Text(
          isReciting ? 'ردد الحركة الآن' : 'استمع للحركة',
          style: TextStyle(
            color: isReciting ? Colors.orange : const Color(0xFF81C784),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildHiddenPlaceholder(bool isReciting) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isReciting ? Icons.record_voice_over : Icons.hearing,
            size: 52,
            color: (isReciting ? Colors.orange : const Color(0xFF81C784))
                .withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          Text(
            isReciting ? '👄 ردد الحركة غيباً' : '👂 استمع لنطق الحركة',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: (isReciting ? Colors.orange : const Color(0xFF81C784))
                  .withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLetterContent(ArabicLetter letter) {
    final symbol = letter.getSegmentSymbol(currentSegment);
    final title = letter.getSegmentTitle(currentSegment);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Giant letter with diacritic
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: KeyedSubtree(
            key: ValueKey('seg_${currentSegment}_$symbol'),
            child: Text(
              symbol,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 80,
                fontWeight: FontWeight.bold,
                color: AppColors.accentLight,
                height: 1.1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        // Segment title (e.g. الحرف مكسوراً)
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        // 5 Interactive diacritic chips
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) {
            final segNum = index + 1;
            final isSelected = segNum == currentSegment;
            final segSymbol = letter.getSegmentSymbol(segNum);
            final segTitle = letter.getSegmentTitle(segNum);

            return GestureDetector(
              onTap: onSegmentSelected != null
                  ? () => onSegmentSelected!(segNum)
                  : null,
              child: Tooltip(
                message: segTitle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF4CAF50)
                        : Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.15),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF4CAF50)
                                  .withValues(alpha: 0.5),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      segSymbol,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFallbackContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Text(
        track.displayName,
        style: const TextStyle(
          fontFamily: 'Amiri',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildFooter(ArabicLetter? letter) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          letter != null ? '${letter.name} (${letter.makhrajGroup})' : 'مخارج الحروف',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
        Text(
          'مقطع $currentSegment من $totalSegments',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
