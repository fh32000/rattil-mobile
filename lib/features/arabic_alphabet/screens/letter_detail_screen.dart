import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/arabic_letter.dart';
import '../../../data/sources/arabic_alphabet_data.dart';
import '../../player/providers/audio_provider.dart';

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
  bool _isCurrentLetterPlaying(AsyncValue<dynamic> currentTrackAsync) {
    final track = currentTrackAsync.valueOrNull;
    if (track == null) return false;
    return track.id == 'single_${_letter?.assetPath}';
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

  Future<void> _togglePlay() async {
    final handler = ref.read(audioHandlerProvider);
    final currentTrack = ref.read(currentTrackProvider).valueOrNull;
    final isPlaying = ref.read(isPlayingProvider).valueOrNull ?? false;

    // If this letter is already loaded, just toggle play/pause
    if (currentTrack?.id == 'single_${_letter?.assetPath}') {
      if (isPlaying) {
        await handler.pause();
      } else {
        await handler.play();
      }
    } else {
      // Play this letter through the main audio handler
      await handler.playSingleAsset(
        assetPath: _letter!.assetPath,
        title: 'حرف ${_letter!.name}',
        artist: 'مخارج الحروف',
      );
    }
  }

  void _navigate(int delta) {
    final newNum = _currentNumber + delta;
    if (newNum >= 1 && newNum <= 28) {
      // Stop current playback when navigating
      final handler = ref.read(audioHandlerProvider);
      handler.stop();
      setState(() {
        _currentNumber = newNum;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      body: CustomScrollView(
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
                          letter.arabicLetter,
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
              padding: const EdgeInsets.all(20),
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

                  // Play button row
                  Container(
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
                              'الاستشهاد الصوتي',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'استمع لمخرج الحرف بحركاته المختلفة من القرآن الكريم',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: _togglePlay,
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
                                        color: AppColors.accent.withValues(
                                          alpha: 0.4,
                                        ),
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
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Prev / Next navigation
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: hasPrev ? () => _navigate(-1) : null,
                          icon: const Icon(Icons.arrow_forward_ios, size: 16),
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
                          icon: const Icon(Icons.arrow_back_ios, size: 16),
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
    );
  }
}
