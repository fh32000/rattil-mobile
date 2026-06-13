import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/audio_track.dart';
import '../../../data/models/playlist.dart';
import '../../../data/repositories/playlist_repository.dart';
import '../../../data/sources/juz_amma_data.dart';
import '../../player/providers/audio_provider.dart';
import '../../player/widgets/mini_player.dart';

// Playlist providers
final playlistRepoProvider = Provider((ref) => PlaylistRepository());

final playlistsProvider =
    StateNotifierProvider<PlaylistsNotifier, List<Playlist>>((ref) {
  return PlaylistsNotifier(ref.watch(playlistRepoProvider));
});

class PlaylistsNotifier extends StateNotifier<List<Playlist>> {
  final PlaylistRepository _repo;

  PlaylistsNotifier(this._repo) : super(_repo.getAllPlaylists());

  void refresh() {
    state = _repo.getAllPlaylists();
  }

  void create(String name) {
    final playlist = Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      trackIds: [],
      createdAt: DateTime.now(),
    );
    _repo.savePlaylist(playlist);
    refresh();
  }

  void delete(String id) {
    _repo.deletePlaylist(id);
    refresh();
  }

  void addTrack(String playlistId, String trackId) {
    _repo.addTrackToPlaylist(playlistId, trackId);
    refresh();
  }

  void removeTrack(String playlistId, String trackId) {
    _repo.removeTrackFromPlaylist(playlistId, trackId);
    refresh();
  }

  void reorderTrack(String playlistId, int oldIndex, int newIndex) {
    _repo.reorderTracks(playlistId, oldIndex, newIndex);
    refresh();
  }

  void sortTracksBySurahNumber(String playlistId) {
    _repo.sortTracksBySurahNumber(playlistId);
    refresh();
  }
}

class PlaylistsScreen extends ConsumerWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(playlistsProvider);
    final handler = ref.watch(audioHandlerProvider);
    final hasTrack = ref.watch(currentTrackProvider).valueOrNull != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('قوائم التشغيل'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          if (playlists.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.playlist_play,
                    size: 80,
                    color: AppColors.textSecondaryDark.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد قوائم تشغيل',
                    style: TextStyle(
                      color: AppColors.textSecondaryDark,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'أنشئ قائمة تشغيل جديدة',
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
              padding: const EdgeInsets.only(
                bottom: AppConstants.miniPlayerBottomPadding,
              ),
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlists[index];
                return Dismissible(
                  key: Key(playlist.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 24),
                    color: AppColors.error.withValues(alpha: 0.2),
                    child: const Icon(Icons.delete, color: AppColors.error),
                  ),
                  onDismissed: (_) {
                    ref.read(playlistsProvider.notifier).delete(playlist.id);
                  },
                  child: ListTile(
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.accent.withValues(alpha: 0.15),
                      ),
                      child: const Icon(
                        Icons.playlist_play,
                        color: AppColors.accent,
                      ),
                    ),
                    title: Text(playlist.name),
                    subtitle: Text('${playlist.trackIds.length} مقطع'),
                    trailing: IconButton(
                      icon: const Icon(Icons.play_arrow_rounded),
                      color: AppColors.accent,
                      onPressed: () {
                        if (playlist.trackIds.isNotEmpty) {
                          final allTracks = JuzAmmaData.tracks;
                          final playlistTracks = playlist.trackIds
                              .map((id) {
                                try {
                                  return allTracks
                                      .firstWhere((t) => t.id == id);
                                } catch (_) {
                                  return null;
                                }
                              })
                              .whereType<AudioTrack>()
                              .toList();
                          if (playlistTracks.isNotEmpty) {
                            handler.loadTracks(
                                playlistTracks, startIndex: 0);
                          }
                        }
                      },
                    ),
                    onTap: () {
                      _showPlaylistDetail(context, ref, playlist, handler);
                    },
                  ),
                );
              },
            ),

          Positioned(
            left: 16,
            bottom: hasTrack
                ? AppConstants.miniPlayerHeight + 8
                : 16,
            child: FloatingActionButton(
              onPressed: () => _showCreateDialog(context, ref),
              child: const Icon(Icons.add),
            ),
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

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('قائمة تشغيل جديدة'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'اسم القائمة',
          ),
          autofocus: true,
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                ref.read(playlistsProvider.notifier).create(name);
                Navigator.pop(context);
              }
            },
            child: const Text('إنشاء'),
          ),
        ],
      ),
    );
  }

  void _showPlaylistDetail(
    BuildContext context,
    WidgetRef ref,
    Playlist playlist,
    dynamic handler,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _PlaylistDetailSheet(
        playlist: playlist,
        handler: handler,
      ),
    );
  }
}

class _PlaylistDetailSheet extends ConsumerStatefulWidget {
  final Playlist playlist;
  final dynamic handler;

  const _PlaylistDetailSheet({
    required this.playlist,
    required this.handler,
  });

  @override
  ConsumerState<_PlaylistDetailSheet> createState() =>
      _PlaylistDetailSheetState();
}

class _PlaylistDetailSheetState extends ConsumerState<_PlaylistDetailSheet> {
  late DraggableScrollableController _dragController;

  @override
  void initState() {
    super.initState();
    _dragController = DraggableScrollableController();
  }

  @override
  void dispose() {
    _dragController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playlists = ref.watch(playlistsProvider);
    final playlist = playlists.firstWhere(
      (p) => p.id == widget.playlist.id,
      orElse: () => widget.playlist,
    );
    final handler = widget.handler;
    final allTracks = JuzAmmaData.tracks;
    final playlistTracks = playlist.trackIds
        .map((id) {
          try {
            return allTracks.firstWhere((t) => t.id == id);
          } catch (_) {
            return null;
          }
        })
        .whereType<AudioTrack>()
        .toList();
    final currentTrack = ref.watch(currentTrackProvider).valueOrNull;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      controller: _dragController,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    playlist.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  // Play all
                  if (playlistTracks.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.play_circle_fill_rounded),
                      color: AppColors.accent,
                      tooltip: 'تشغيل الكل',
                      onPressed: () {
                        handler.loadTracks(
                          playlistTracks,
                          startIndex: 0,
                        );
                      },
                    ),
                  // Sort by surah number
                  IconButton(
                    icon: const Icon(Icons.sort),
                    tooltip: 'ترتيب حسب رقم السورة',
                    onPressed: playlistTracks.isEmpty
                        ? null
                        : () {
                            ref
                                .read(playlistsProvider.notifier)
                                .sortTracksBySurahNumber(playlist.id);
                          },
                  ),
                  // Add tracks
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      _showAddTrackSheet(context, ref, playlist);
                    },
                  ),
                ],
              ),
            ),

            Expanded(
              child: playlistTracks.isEmpty
                  ? const Center(
                      child: Text('لا توجد مقاطع في هذه القائمة'),
                    )
                  : ReorderableListView.builder(
                      scrollController: scrollController,
                      itemCount: playlistTracks.length,
                      onReorder: (oldIndex, newIndex) {
                        if (newIndex > oldIndex) newIndex--;
                        ref
                            .read(playlistsProvider.notifier)
                            .reorderTrack(playlist.id, oldIndex, newIndex);
                      },
                      itemBuilder: (context, index) {
                        final track = playlistTracks[index];
                        final isPlaying = currentTrack?.id == track.id;
                        return ListTile(
                          key: ValueKey(track.id),
                          leading: CircleAvatar(
                            backgroundColor: isPlaying
                                ? AppColors.accent.withValues(alpha: 0.3)
                                : AppColors.primary.withValues(alpha: 0.2),
                            child: isPlaying
                                ? const Icon(
                                    Icons.play_arrow_rounded,
                                    color: AppColors.accent,
                                    size: 20,
                                  )
                                : Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: AppColors.primaryLight,
                                    ),
                                  ),
                          ),
                          title: Text(
                            'سورة ${track.surahNameArabic}',
                            style: TextStyle(
                              color: isPlaying ? AppColors.accent : null,
                              fontWeight:
                                  isPlaying ? FontWeight.bold : null,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.play_arrow_rounded,
                                  color: AppColors.accent,
                                ),
                                onPressed: () {
                                  handler.loadTracks(
                                    playlistTracks,
                                    startIndex: index,
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  color: AppColors.error,
                                  size: 20,
                                ),
                                onPressed: () {
                                  ref
                                      .read(playlistsProvider.notifier)
                                      .removeTrack(
                                        playlist.id,
                                        track.id,
                                      );
                                },
                              ),
                              const Icon(
                                Icons.drag_handle,
                                color: AppColors.textSecondaryDark,
                                size: 20,
                              ),
                            ],
                          ),
                          onTap: () {
                            handler.loadTracks(
                              playlistTracks,
                              startIndex: index,
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  void _showAddTrackSheet(
    BuildContext context,
    WidgetRef ref,
    Playlist playlist,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _AddTrackSheet(playlist: playlist),
    );
  }
}

class _AddTrackSheet extends ConsumerStatefulWidget {
  final Playlist playlist;

  const _AddTrackSheet({required this.playlist});

  @override
  ConsumerState<_AddTrackSheet> createState() => _AddTrackSheetState();
}

class _AddTrackSheetState extends ConsumerState<_AddTrackSheet> {
  @override
  Widget build(BuildContext context) {
    final playlists = ref.watch(playlistsProvider);
    final playlist = playlists.firstWhere(
      (p) => p.id == widget.playlist.id,
      orElse: () => widget.playlist,
    );
    final allTracks = JuzAmmaData.tracks;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'إضافة مقطع',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: allTracks.length,
                itemBuilder: (context, index) {
                  final track = allTracks[index];
                  final isInPlaylist = playlist.trackIds.contains(track.id);
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isInPlaylist
                          ? AppColors.success.withValues(alpha: 0.2)
                          : AppColors.primary.withValues(alpha: 0.2),
                      child: isInPlaylist
                          ? const Icon(
                              Icons.check,
                              color: AppColors.success,
                              size: 20,
                            )
                          : Text(
                              track.surahNumber.toString(),
                              style:
                                  TextStyle(color: AppColors.primaryLight),
                            ),
                    ),
                    title: Text('سورة ${track.surahNameArabic}'),
                    trailing: IconButton(
                      icon: Icon(
                        isInPlaylist
                            ? Icons.check_circle
                            : Icons.add_circle_outline,
                        color: isInPlaylist
                            ? AppColors.success
                            : AppColors.accent,
                      ),
                      onPressed: () {
                        if (isInPlaylist) {
                          ref
                              .read(playlistsProvider.notifier)
                              .removeTrack(playlist.id, track.id);
                        } else {
                          ref
                              .read(playlistsProvider.notifier)
                              .addTrack(playlist.id, track.id);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
