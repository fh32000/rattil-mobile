import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/sources/juz_amma_data.dart';
import '../../player/providers/audio_provider.dart';
import '../../player/widgets/mini_player.dart';
import '../widgets/surah_list_tile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahs = JuzAmmaData.surahs;
    final theme = Theme.of(context);

    return Scaffold(
      drawer: _buildDrawer(context),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // App bar
              SliverAppBar(
                expandedHeight: 240,
                leading: Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    'ورتِّله',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Container(
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'assets/images/app_icon.png',
                              width: 60,
                              height: 60,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.accent.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              'جزء عمّ',
                              style: TextStyle(
                                color: AppColors.accentLight,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () => context.push('/search'),
                  ),
                ],
              ),

              // Quick actions
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _buildQuickAction(
                        context,
                        icon: Icons.favorite,
                        label: 'المفضلة',
                        color: AppColors.error,
                        onTap: () => context.push('/favorites'),
                      ),
                      const SizedBox(width: 12),
                      _buildQuickAction(
                        context,
                        icon: Icons.playlist_play,
                        label: 'قوائم التشغيل',
                        color: AppColors.accent,
                        onTap: () => context.push('/playlists'),
                      ),
                      const SizedBox(width: 12),
                      _buildQuickAction(
                        context,
                        icon: Icons.person,
                        label: 'القارئ',
                        color: AppColors.primaryLight,
                        onTap: () => context.push('/reciter'),
                      ),
                      const SizedBox(width: 12),
                      _buildQuickAction(
                        context,
                        icon: Icons.abc,
                        label: 'الحروف',
                        color: const Color(0xFF6A1B9A),
                        onTap: () => context.push('/arabic-alphabet'),
                      ),
                    ],
                  ),
                ),
              ),

              // Section header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
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
                      Text(
                        'السور',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${surahs.length} سورة',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Surah list
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final surah = surahs[index];
                    final currentTrack = ref
                        .watch(currentTrackProvider)
                        .valueOrNull;
                    final isPlaying =
                        ref.watch(isPlayingProvider).valueOrNull ?? false;
                    final isCurrentTrack =
                        currentTrack?.surahNumber == surah.number;

                    return SurahListTile(
                      surah: surah,
                      isCurrentTrack: isCurrentTrack,
                      isPlaying: isPlaying,
                      onTap: () => context.push('/surah/${surah.number}'),
                      onPlay: () {
                        final handler = ref.read(audioHandlerProvider);
                        if (isCurrentTrack) {
                          // Toggle play/pause for current track
                          if (isPlaying) {
                            handler.pause();
                          } else {
                            handler.play();
                          }
                        } else {
                          // Play new track
                          handler.loadTracks(
                            JuzAmmaData.tracks,
                            startIndex: index,
                          );
                        }
                      },
                    );
                  }, childCount: surahs.length),
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

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.backgroundDark,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      'assets/images/app_icon.png',
                      width: 56,
                      height: 56,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'ورتِّله',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'تطبيق القرآن الكريم',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            _buildDrawerItem(
              context,
              icon: Icons.home,
              label: 'الرئيسية',
              onTap: () => Navigator.pop(context),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.favorite,
              label: 'المفضلة',
              onTap: () {
                Navigator.pop(context);
                context.push('/favorites');
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.playlist_play,
              label: 'قوائم التشغيل',
              onTap: () {
                Navigator.pop(context);
                context.push('/playlists');
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.person,
              label: 'القارئ',
              onTap: () {
                Navigator.pop(context);
                context.push('/reciter');
              },
            ),

            _buildDrawerItem(
              context,
              icon: Icons.abc,
              label: 'مخارج الحروف',
              onTap: () {
                Navigator.pop(context);
                context.push('/arabic-alphabet');
              },
            ),

            const Divider(color: AppColors.progressInactive),

            _buildDrawerItem(
              context,
              icon: Icons.info_outline,
              label: 'عن التطبيق',
              onTap: () {
                Navigator.pop(context);
                context.push('/about');
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.support_agent,
              label: 'الدعم والتواصل',
              onTap: () {
                Navigator.pop(context);
                context.push('/support');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.accentLight, size: 22),
      title: Text(label, style: const TextStyle(fontSize: 15)),
      onTap: onTap,
      dense: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
    );
  }
}
