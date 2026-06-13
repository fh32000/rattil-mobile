import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/surah.dart';
import '../../../data/sources/juz_amma_data.dart';
import '../../player/providers/audio_provider.dart';
import '../../player/widgets/mini_player.dart';

class SurahDetailScreen extends ConsumerWidget {
  final int surahNumber;

  const SurahDetailScreen({super.key, required this.surahNumber});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surah = JuzAmmaData.getSurahByNumber(surahNumber);
    final track = JuzAmmaData.getTrackBySurahNumber(surahNumber);
    final theme = Theme.of(context);
    final handler = ref.watch(audioHandlerProvider);
    final favorites = ref.watch(favoritesProvider);
    final isFav = track != null && favorites.contains(track.id);

    if (surah == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('السورة غير موجودة')),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Header
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    'سورة ${surah.nameArabic}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  background: _buildHeader(surah, theme),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // Surah details
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Info cards
                      Row(
                        children: [
                          _buildInfoCard(
                            icon: Icons.numbers,
                            label: 'رقم السورة',
                            value: '${surah.number}',
                            theme: theme,
                          ),
                          const SizedBox(width: 12),
                          _buildInfoCard(
                            icon: Icons.bookmark,
                            label: 'عدد الآيات',
                            value: '${surah.versesCount}',
                            theme: theme,
                          ),
                          const SizedBox(width: 12),
                          _buildInfoCard(
                            icon: Icons.menu_book,
                            label: 'الصفحة',
                            value: '${surah.pageStart}',
                            theme: theme,
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Revelation type
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_city,
                              color: AppColors.accent,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'سورة ${surah.revelationType}',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Play button
                      if (track != null)
                        _buildPlaySection(track, handler, isFav, ref, theme),

                      const SizedBox(height: AppConstants.miniPlayerBottomPadding),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Mini player
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MiniPlayer(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Surah surah, ThemeData theme) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
            AppColors.backgroundDark,
          ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent.withValues(alpha: 0.15),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    surah.number.toString(),
                    style: TextStyle(
                      color: AppColors.accentLight,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryLight, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaySection(
    dynamic track,
    dynamic handler,
    bool isFav,
    WidgetRef ref,
    ThemeData theme,
  ) {
    return Column(
      children: [
        // Play all from this surah
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              final tracks = JuzAmmaData.tracks;
              final index =
                  tracks.indexWhere((t) => t.surahNumber == surahNumber);
              handler.loadTracks(tracks, startIndex: index >= 0 ? index : 0);
            },
            icon: const Icon(Icons.play_arrow_rounded, size: 28),
            label: const Text(
              'تشغيل السورة',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Secondary actions
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ref
                      .read(favoritesProvider.notifier)
                      .toggle(track.id as String);
                },
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? AppColors.error : null,
                  size: 20,
                ),
                label: Text(isFav ? 'في المفضلة' : 'أضف للمفضلة'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
