import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/memorization_settings.dart';
import '../services/verse_service.dart';

/// Displays the previous, current, and next ayah with smooth transitions.
///
/// Designed for the Hifz memorization view. The current ayah is shown large and
/// highlighted (gold), while the surrounding ayat are smaller and dimmed.
///
/// When [hideVerses] is true, the verse text is replaced by a placeholder
/// icon + message for distraction‑free memorisation.
class VerseDisplayWidget extends StatelessWidget {
  final int surahNumber;
  final int currentAudioIndex; // 1‑based audio file index
  final int totalAudioFiles;
  final HifzPhase phase;
  final bool hideVerses;

  const VerseDisplayWidget({
    super.key,
    required this.surahNumber,
    required this.currentAudioIndex,
    required this.totalAudioFiles,
    required this.phase,
    this.hideVerses = false,
  });

  @override
  Widget build(BuildContext context) {
    final service = VerseService();
    final isReciting = phase == HifzPhase.reciting;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              const Color(0xFF1B5E20),
              const Color(0xFF0D3D12),
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
            const SizedBox(height: 16),
            if (hideVerses) ...[
              _buildHiddenPlaceholder(isReciting),
            ] else ...[
              _buildVerseContent(service),
            ],
            const SizedBox(height: 12),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildVerseContent(VerseService service) {
    final prevAudioIndex =
        currentAudioIndex > 1 ? currentAudioIndex - 1 : null;
    final nextAudioIndex =
        currentAudioIndex < totalAudioFiles ? currentAudioIndex + 1 : null;

    final prevText = prevAudioIndex != null
        ? service.getTextForAudioIndex(surahNumber, prevAudioIndex)
        : null;
    final currentText = service.getTextForAudioIndex(
      surahNumber,
      currentAudioIndex,
    );
    final nextText = nextAudioIndex != null
        ? service.getTextForAudioIndex(surahNumber, nextAudioIndex)
        : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildVerseSlot(text: prevText, isCurrent: false, isPrev: true),
        if (prevText != null) ...[
          const SizedBox(height: 8),
          _buildDivider(),
          const SizedBox(height: 8),
        ],
        _buildVerseSlot(text: currentText, isCurrent: true, isPrev: false),
        if (nextText != null) ...[
          const SizedBox(height: 8),
          _buildDivider(),
          const SizedBox(height: 8),
        ],
        _buildVerseSlot(text: nextText, isCurrent: false, isPrev: false),
      ],
    );
  }

  Widget _buildHiddenPlaceholder(bool isReciting) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isReciting ? Icons.record_voice_over : Icons.hearing,
          size: 48,
          color: (isReciting ? Colors.orange : const Color(0xFF81C784))
              .withValues(alpha: 0.6),
        ),
        const SizedBox(height: 12),
        Text(
          isReciting ? '👄 ردد الآية الآن' : '👂 استمع للآية',
          style: const TextStyle(
            fontFamily: 'Amiri',
            fontSize: 22,
            fontWeight: FontWeight.w600,
            height: 1.6,
          ).copyWith(
            color: (isReciting ? Colors.orange : const Color(0xFF81C784))
                .withValues(alpha: 0.8),
          ),
        ),
      ],
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
          isReciting ? 'اقرأ الآية' : 'استمع للآية',
          style: TextStyle(
            color: isReciting ? Colors.orange : const Color(0xFF81C784),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildVerseSlot({
    required String? text,
    required bool isCurrent,
    required bool isPrev,
  }) {
    if (text == null) return const SizedBox.shrink();

    final Widget verseWidget = Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'Amiri',
        fontSize: isCurrent ? 28 : 20,
        fontWeight: isCurrent ? FontWeight.bold : FontWeight.w400,
        color: isCurrent
            ? AppColors.accentLight
            : Colors.white.withValues(alpha: 0.55),
        height: 1.8,
      ),
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      child: KeyedSubtree(
        key: ValueKey('${isCurrent ? 'current' : isPrev ? 'prev' : 'next'}_$text'),
        child: verseWidget,
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: Colors.white.withValues(alpha: 0.15),
    );
  }

  Widget _buildFooter() {
    final service = VerseService();
    final verse = service.getVerseForAudioIndex(surahNumber, currentAudioIndex);

    return Text(
      verse < 1 ? 'بسملة' : 'الآية $verse',
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.5),
        fontSize: 12,
      ),
    );
  }
}
