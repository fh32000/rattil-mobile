import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/arabic_letter.dart';
import '../../../data/sources/arabic_alphabet_data.dart';
import '../../player/providers/audio_provider.dart';
import '../../player/widgets/mini_player.dart';
import '../widgets/letter_card.dart';

class ArabicAlphabetScreen extends ConsumerStatefulWidget {
  const ArabicAlphabetScreen({super.key});

  @override
  ConsumerState<ArabicAlphabetScreen> createState() =>
      _ArabicAlphabetScreenState();
}

class _ArabicAlphabetScreenState extends ConsumerState<ArabicAlphabetScreen> {
  String _selectedGroup = 'الكل';

  List<ArabicLetter> get _filteredLetters =>
      ArabicAlphabetData.getByGroup(_selectedGroup);

  Future<void> _playLetter(ArabicLetter letter) async {
    final handler = ref.read(audioHandlerProvider);
    final currentTrack = ref.read(currentTrackProvider).valueOrNull;
    final isPlaying = ref.read(isPlayingProvider).valueOrNull ?? false;

    // If this letter is already loaded, toggle play/pause
    if (currentTrack?.id == 'letter_${letter.number}') {
      if (isPlaying) {
        await handler.pause();
      } else {
        await handler.play();
      }
    } else {
      // Load all letters as a playlist, starting from this letter
      final letterTracks = ArabicAlphabetData.toAudioTracks();
      final startIndex = letter.number - 1; // 1-based number → 0-based index
      await handler.loadLetterTracks(
        letterTracks: letterTracks,
        startIndex: startIndex,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final letters = _filteredLetters;

    // Watch audio state from main handler
    final currentTrack = ref.watch(currentTrackProvider).valueOrNull;
    final isPlaying = ref.watch(isPlayingProvider).valueOrNull ?? false;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // App bar
              SliverAppBar(
                expandedHeight: 160,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: const Text(
                    'مخارج الحروف',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          Color(0xFF1565C0),
                          AppColors.primaryDark,
                          AppColors.backgroundDark,
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 50),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.accent.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: Text(
                                'من الألف إلى الياء • 28 حرفاً',
                                style: TextStyle(
                                  color: AppColors.accentLight,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Group filter chips
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تصفية حسب المخرج',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: ArabicAlphabetData.groups.map((group) {
                          final isSelected = _selectedGroup == group;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedGroup = group),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.accent
                                    : AppColors.accent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.accent
                                      : AppColors.accent.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Text(
                                group,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.black
                                      : AppColors.accent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              // Legend
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 6,
                    children: [
                      _buildLegendItem('الحلق', const Color(0xFF1565C0)),
                      _buildLegendItem('اللسان', AppColors.primary),
                      _buildLegendItem('الشفتان', const Color(0xFF6A1B9A)),
                    ],
                  ),
                ),
              ),

              // Grid of letter cards
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.8,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final letter = letters[index];
                    final isLetterPlaying =
                        currentTrack?.id == 'letter_${letter.number}' &&
                        isPlaying;
                    return LetterCard(
                      letter: letter,
                      isPlaying: isLetterPlaying,
                      onTap: () =>
                          context.push('/arabic-alphabet/${letter.number}'),
                      onPlay: () => _playLetter(letter),
                    );
                  }, childCount: letters.length),
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

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
