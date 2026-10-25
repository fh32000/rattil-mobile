import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/arabic_letter.dart';
import '../../../data/models/audio_track.dart';
import '../../../data/models/memorization_settings.dart';
import '../../../data/sources/arabic_alphabet_data.dart';
import '../../player/providers/audio_provider.dart';
import '../../player/widgets/letter_repetition_display_widget.dart';
import '../../player/widgets/mini_player.dart';

class LetterDetailScreen extends ConsumerStatefulWidget {
  final int letterNumber;
  const LetterDetailScreen({super.key, required this.letterNumber});

  @override
  ConsumerState<LetterDetailScreen> createState() => _LetterDetailScreenState();
}

class _LetterDetailScreenState extends ConsumerState<LetterDetailScreen> {
  late int _currentNumber;

  @override
  void initState() {
    super.initState();
    _currentNumber = widget.letterNumber;
  }

  ArabicLetter? get _letter => ArabicAlphabetData.getByNumber(_currentNumber);

  /// Check if this letter's audio is what's currently loaded in the main player
  bool _isCurrentLetterPlaying(AsyncValue<AudioTrack?> currentTrackAsync) {
    final track = currentTrackAsync.valueOrNull;
    if (track == null || !track.isLetter) return false;
    return track.surahNumber == _currentNumber ||
        track.id.startsWith('letter_${_currentNumber.toString().padLeft(3, '0')}') ||
        track.id == 'letter_$_currentNumber';
  }

  Color get _groupColor {
    switch (_letter?.makhrajGroup) {
      case 'الحلق':
        return const Color(0xFF1565C0);
      case 'اللسان':
        return AppColors.primary;
      case 'الشفتان':
        return const Color(0xFF6A1B9A);
      default:
        return AppColors.primaryDark;
    }
  }

  void _syncCurrentNumberFromTrack() {
    final track = ref.read(currentTrackProvider).valueOrNull;
    if (track == null || !track.isLetter) return;
    final letterNum = track.surahNumber > 0
        ? track.surahNumber
        : LetterRepetitionDisplayWidget.resolveLetterNumber(track);
    if (letterNum != null && letterNum >= 1 && letterNum <= 28 && letterNum != _currentNumber) {
      setState(() {
        _currentNumber = letterNum;
      });
    }
  }

  Future<void> _togglePlay({LetterHarakaType? harakaType, int startIndex = 0}) async {
    final handler = ref.read(audioHandlerProvider);
    final isPlaying = ref.read(isPlayingProvider).valueOrNull ?? false;
    final isLetterPlaying = _isCurrentLetterPlaying(ref.read(currentTrackProvider));

    if (isLetterPlaying && harakaType == null && startIndex == 0) {
      if (isPlaying) {
        await handler.pause();
      } else {
        await handler.play();
      }
    } else {
      await handler.playLetterSequence(
        letterNumber: _currentNumber,
        harakaType: harakaType,
        startIndex: startIndex,
      );
    }
  }

  void _navigate(int delta) {
    final newNum = _currentNumber + delta;
    if (newNum >= 1 && newNum <= 28) {
      setState(() {
        _currentNumber = newNum;
      });
      final handler = ref.read(audioHandlerProvider);
      handler.playLetterSequence(letterNumber: newNum);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Auto-sync displayed letter when playback advances
    _syncCurrentNumberFromTrack();

    final letter = _letter;
    if (letter == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('الحرف')),
        body: const Center(child: Text('حرف غير موجود')),
      );
    }

    final theme = Theme.of(context);
    final color = _groupColor;
    final hasPrev = _currentNumber > 1;
    final hasNext = _currentNumber < 28;

    // Watch audio state for this letter
    final currentTrackAsync = ref.watch(currentTrackProvider);
    final isLetterPlaying = _isCurrentLetterPlaying(currentTrackAsync);
    final isPlaying =
        isLetterPlaying && (ref.watch(isPlayingProvider).valueOrNull ?? false);

    final arabicLetter = letter.arabicLetter;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Animated app bar
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    letter.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  background: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          color,
                          color.withValues(alpha: 0.7),
                          AppColors.backgroundDark,
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Giant letter
                            Text(
                              arabicLetter,
                              style: TextStyle(
                                fontSize: 100,
                                color: Colors.white,
                                fontFamily: 'Amiri',
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 50),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, AppConstants.miniPlayerBottomPadding),
                  child: Column(
                    children: [
                      // Makhraj info card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.cardTheme.color,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Group badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                letter.makhrajGroup,
                                style: TextStyle(
                                  color: color,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'مخرج الحرف',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              letter.makhrajDetail,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Main sequential player card
                      _buildPlayCard(
                        context: context,
                        color: color,
                        letter: letter,
                        currentTrack: currentTrackAsync.valueOrNull,
                        isPlaying: isPlaying,
                        isLetterPlaying: isLetterPlaying,
                      ),

                      const SizedBox(height: 20),

                      // Harakat & multiple Quranic examples section
                      _buildHarakatSection(
                        context: context,
                        letter: letter,
                        color: color,
                        currentTrack: currentTrackAsync.valueOrNull,
                        isPlaying: isPlaying,
                        isLetterPlaying: isLetterPlaying,
                      ),

                      const SizedBox(height: 20),

                      // Letter Repetition Mode Card (وضع ترديد الحركات)
                      _buildRepetitionCard(
                        context: context,
                        letter: letter,
                        color: color,
                      ),

                      const SizedBox(height: 20),

                      // Prev / Next navigation
                      Row(
                        textDirection: TextDirection.rtl,
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: hasPrev ? () => _navigate(-1) : null,
                              icon: const Icon(Icons.arrow_back_ios, size: 16),
                              label: Text(
                                hasPrev
                                    ? ArabicAlphabetData.getByNumber(
                                            _currentNumber - 1,
                                          )?.name ??
                                          ''
                                    : '',
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: hasNext ? () => _navigate(1) : null,
                              icon: const Icon(Icons.arrow_forward_ios, size: 16),
                              label: Text(
                                hasNext
                                    ? ArabicAlphabetData.getByNumber(
                                            _currentNumber + 1,
                                          )?.name ??
                                          ''
                                    : '',
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Mini player
          const Positioned(left: 0, right: 0, bottom: 0, child: MiniPlayer()),
        ],
      ),
    );
  }

  Widget _buildPlayCard({
    required BuildContext context,
    required Color color,
    required ArabicLetter letter,
    required AudioTrack? currentTrack,
    required bool isPlaying,
    required bool isLetterPlaying,
  }) {
    final theme = Theme.of(context);
    final handler = ref.read(audioHandlerProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'الاستشهاد الصوتي والتسلسل الكامل',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'اسم الحرف ⬅️ تعريف الحركة ⬅️ مثال 1 ⬅️ مثال آخر ⬅️ مثال 2...',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          if (isLetterPlaying && currentTrack != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.volume_up_rounded,
                    size: 16,
                    color: AppColors.accentLight,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatCurrentSegmentLabel(currentTrack),
                    style: const TextStyle(
                      color: AppColors.accentLight,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Skip previous segment
              IconButton(
                icon: const Icon(Icons.skip_previous_rounded, size: 28),
                color: isLetterPlaying ? Colors.white : Colors.white38,
                onPressed: isLetterPlaying ? () => handler.skipToPrevious() : null,
              ),
              const SizedBox(width: 12),
              // Main Play/Pause
              GestureDetector(
                onTap: () => _togglePlay(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isPlaying
                        ? AppColors.accent
                        : color.withValues(alpha: 0.2),
                    boxShadow: isPlaying
                        ? [
                            BoxShadow(
                              color: AppColors.accent.withValues(alpha: 0.4),
                              blurRadius: 20,
                              spreadRadius: 4,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: isPlaying ? Colors.black : Colors.white,
                    size: 38,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Skip next segment
              IconButton(
                icon: const Icon(Icons.skip_next_rounded, size: 28),
                color: isLetterPlaying ? Colors.white : Colors.white38,
                onPressed: isLetterPlaying ? () => handler.skipToNext() : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHarakatSection({
    required BuildContext context,
    required ArabicLetter letter,
    required Color color,
    required AudioTrack? currentTrack,
    required bool isPlaying,
    required bool isLetterPlaying,
  }) {
    final theme = Theme.of(context);
    final harakat = letter.allHarakat;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'الحركات والأمثلة القرآنية المتعددة',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'استمع لتعريف كل حركة وأمثلتها القرآنية المتعددة بصوت الشيخ عمر الخامر',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 14),
        ...harakat.map((h) {
          final isHarakaActive = isLetterPlaying &&
              currentTrack?.harakaName == h.nameArabic;
          final isHarakaPlaying = isHarakaActive && isPlaying;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isHarakaActive
                    ? color.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.06),
                width: isHarakaActive ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Diacritic Symbol
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          h.symbol,
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            h.nameArabic,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'التعريف + ${h.exampleCount} أمثلة قرآنية متتالية',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Play this Haraka sequence
                    IconButton(
                      tooltip: 'تشغيل تسلسل ${h.nameArabic}',
                      icon: Icon(
                        isHarakaPlaying
                            ? Icons.pause_circle_filled_rounded
                            : Icons.play_circle_filled_rounded,
                        color: isHarakaActive ? AppColors.accent : color,
                        size: 32,
                      ),
                      onPressed: () => _togglePlay(harakaType: h.type),
                    ),
                    // Start Hifz mode for this Haraka
                    IconButton(
                      tooltip: 'ترديد ${h.nameArabic}',
                      icon: Icon(
                        Icons.repeat_rounded,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        size: 24,
                      ),
                      onPressed: () {
                        final handler = ref.read(audioHandlerProvider);
                        handler.enableHifzMode(
                          letterNumber: _currentNumber,
                          harakaType: h.type,
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Chips for Definition and multiple Examples
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildSegmentChip(
                      label: 'التعريف',
                      isActive: isHarakaActive && (currentTrack?.isHarakaDefinition ?? false),
                      color: color,
                      onTap: () => _togglePlay(
                        harakaType: h.type,
                        startIndex: 1, // index 1 is definition
                      ),
                    ),
                    ...List.generate(h.exampleCount, (exIndex) {
                      final exNum = exIndex + 1;
                      final isExActive = isHarakaActive &&
                          (currentTrack?.isExample ?? false) &&
                          currentTrack?.exampleNumber == exNum;
                      final targetIndex = exNum * 2;
                      return _buildSegmentChip(
                        label: 'مثال $exNum',
                        isActive: isExActive,
                        color: color,
                        onTap: () => _togglePlay(
                          harakaType: h.type,
                          startIndex: targetIndex,
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSegmentChip({
    required String label,
    required bool isActive,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.accent
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive
                ? AppColors.accent
                : Colors.white.withValues(alpha: 0.12),
            width: isActive ? 1.5 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isActive) ...[
              const Icon(
                Icons.volume_up_rounded,
                size: 14,
                color: Colors.black,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? Colors.black : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepetitionCard({
    required BuildContext context,
    required ArabicLetter letter,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isHifzActive = ref.watch(isHifzModeActiveProvider);
    final memState = ref.watch(memorizationPlaybackStateProvider).valueOrNull;
    final currentTrack = ref.watch(currentTrackProvider).valueOrNull;

    final isLetterHifzActive = isHifzActive &&
        currentTrack != null &&
        currentTrack.isAlphabetSegment &&
        (currentTrack.surahNumber == _currentNumber ||
            currentTrack.id.startsWith('letter_${_currentNumber.toString().padLeft(3, '0')}'));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: isLetterHifzActive
            ? Border.all(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.6),
                width: 1.5,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'وضع ترديد الحركات',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLetterHifzActive
                      ? const Color(0xFF4CAF50)
                      : color.withValues(alpha: 0.2),
                  foregroundColor: Colors.white,
                  elevation: isLetterHifzActive ? 4 : 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () async {
                  final handler = ref.read(audioHandlerProvider);
                  if (isLetterHifzActive) {
                    handler.disableHifzMode();
                  } else {
                    await handler.enableHifzMode(letterNumber: _currentNumber);
                  }
                },
                icon: Icon(
                  isLetterHifzActive
                      ? Icons.stop_rounded
                      : Icons.repeat_rounded,
                  size: 18,
                ),
                label: Text(
                  isLetterHifzActive ? 'إيقاف' : 'بدء الترديد',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'ترديد الحرف بأسائه وحركاته مع الاستماع والترديد الذاتي',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 16),

          // 5 Diacritic chips
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(5, (index) {
              final segNum = index + 1;
              final isSelectedSeg = isLetterHifzActive && (memState?.currentAyah == segNum);
              final symbol = letter.getSegmentSymbol(segNum);
              final title = letter.getSegmentTitle(segNum);

              return GestureDetector(
                onTap: () async {
                  final handler = ref.read(audioHandlerProvider);
                  if (!isLetterHifzActive) {
                    await handler.enableHifzMode(letterNumber: _currentNumber);
                  }
                  await handler.jumpToAyah(segNum);
                },
                child: Tooltip(
                  message: title,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isSelectedSeg
                          ? const Color(0xFF4CAF50)
                          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: isSelectedSeg
                          ? [
                              BoxShadow(
                                color: const Color(0xFF4CAF50).withValues(alpha: 0.4),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                      border: Border.all(
                        color: isSelectedSeg
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.1),
                        width: isSelectedSeg ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        symbol,
                        style: TextStyle(
                          fontSize: 22,
                          fontFamily: 'Amiri',
                          fontWeight: FontWeight.bold,
                          color: isSelectedSeg ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          if (isLetterHifzActive && memState != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    letter.getSegmentTitle(memState.currentAyah),
                    style: const TextStyle(
                      color: Color(0xFF81C784),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        memState.phase == HifzPhase.reciting
                            ? Icons.record_voice_over
                            : Icons.hearing,
                        size: 16,
                        color: memState.phase == HifzPhase.reciting
                            ? Colors.orange
                            : const Color(0xFF4CAF50),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        memState.phase == HifzPhase.reciting ? 'ترديد' : 'استماع',
                        style: TextStyle(
                          color: memState.phase == HifzPhase.reciting
                              ? Colors.orange
                              : const Color(0xFF4CAF50),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatCurrentSegmentLabel(AudioTrack track) {
    if (track.isLetterName) {
      return 'اسم الحرف (${track.surahNameArabic})';
    }
    if (track.isHarakaDefinition) {
      return 'تعريف حركة ${track.harakaName ?? ''}';
    }
    if (track.isExample) {
      final exNum = track.exampleNumber != null ? ' ${track.exampleNumber}' : '';
      return '${track.harakaName ?? ''} • مثال قرآني$exNum';
    }
    if (track.isTransition) {
      return 'انتقال: مثال آخر';
    }
    return track.displayName;
  }
}

