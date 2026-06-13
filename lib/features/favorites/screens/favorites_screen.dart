import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/sources/juz_amma_data.dart';
import '../../player/providers/audio_provider.dart';
import '../../player/widgets/mini_player.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final handler = ref.watch(audioHandlerProvider);
    final allTracks = JuzAmmaData.tracks;
    final favTracks =
        allTracks.where((t) => favorites.contains(t.id)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('المفضلة'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          if (favTracks.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: AppColors.textSecondaryDark.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد مقاطع في المفضلة',
                    style: TextStyle(
                      color: AppColors.textSecondaryDark,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'أضف مقاطع من خلال الضغط على ♡',
                    style: TextStyle(
                      color: AppColors.textSecondaryDark.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              padding: const EdgeInsets.only(bottom: AppConstants.miniPlayerBottomPadding),
              itemCount: favTracks.length,
              itemBuilder: (context, index) {
                final track = favTracks[index];
                return Dismissible(
                  key: Key(track.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 24),
                    color: AppColors.error.withValues(alpha: 0.2),
                    child: const Icon(
                      Icons.delete,
                      color: AppColors.error,
                    ),
                  ),
                  onDismissed: (_) {
                    ref.read(favoritesProvider.notifier).toggle(track.id);
                  },
                  child: ListTile(
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          track.surahNumber.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    title: Text('سورة ${track.surahNameArabic}'),
                    subtitle: Text(track.reciterName),
                    trailing: IconButton(
                      icon: const Icon(Icons.play_arrow_rounded),
                      color: AppColors.accent,
                      onPressed: () {
                        handler.loadTracks(
                          favTracks,
                          startIndex: index,
                        );
                      },
                    ),
                    onTap: () {
                      handler.loadTracks(
                        favTracks,
                        startIndex: index,
                      );
                    },
                  ),
                );
              },
            ),

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
}
