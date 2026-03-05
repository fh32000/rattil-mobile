import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/surah.dart';
import '../../../data/sources/juz_amma_data.dart';
import '../../player/providers/audio_provider.dart';
import '../../player/widgets/mini_player.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  List<Surah> _results = JuzAmmaData.surahs;
  String _filter = 'الكل'; // الكل | مكية | مدنية

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search(String query) {
    setState(() {
      var filtered = JuzAmmaData.surahs.where((surah) {
        final q = query.trim().toLowerCase();
        if (q.isEmpty) return true;
        return surah.nameArabic.contains(q) ||
            surah.nameEnglish.toLowerCase().contains(q) ||
            surah.number.toString() == q ||
            surah.pageStart.toString() == q;
      }).toList();

      // Apply filter
      if (_filter == 'مكية') {
        filtered = filtered.where((s) => s.revelationType == 'مكية').toList();
      } else if (_filter == 'مدنية') {
        filtered = filtered.where((s) => s.revelationType == 'مدنية').toList();
      }

      _results = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final handler = ref.watch(audioHandlerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('البحث'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'ابحث باسم السورة أو رقمها أو الصفحة...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              _search('');
                            },
                          )
                        : null,
                  ),
                  textDirection: TextDirection.rtl,
                  onChanged: _search,
                ),
              ),

              // Filters
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildFilterChip('الكل'),
                    const SizedBox(width: 8),
                    _buildFilterChip('مكية'),
                    const SizedBox(width: 8),
                    _buildFilterChip('مدنية'),
                    const Spacer(),
                    Text(
                      '${_results.length} نتيجة',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Results
              Expanded(
                child: _results.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 60,
                              color: AppColors.textSecondaryDark
                                  .withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'لا توجد نتائج',
                              style: TextStyle(
                                color: AppColors.textSecondaryDark,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 100),
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final surah = _results[index];
                          return ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color:
                                    AppColors.primary.withValues(alpha: 0.15),
                              ),
                              child: Center(
                                child: Text(
                                  surah.number.toString(),
                                  style: TextStyle(
                                    color: AppColors.primaryLight,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            title: Text('سورة ${surah.nameArabic}'),
                            subtitle: Text(
                              '${surah.revelationType} · ${surah.versesCount} آية · ص ${surah.pageStart}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.play_arrow_rounded),
                              color: AppColors.accent,
                              onPressed: () {
                                final tracks = JuzAmmaData.tracks;
                                final idx = tracks.indexWhere(
                                    (t) => t.surahNumber == surah.number);
                                handler.loadTracks(tracks,
                                    startIndex: idx >= 0 ? idx : 0);
                              },
                            ),
                            onTap: () {
                              context.push('/surah/${surah.number}');
                            },
                          );
                        },
                      ),
              ),
            ],
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

  Widget _buildFilterChip(String label) {
    final isSelected = _filter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _filter = label;
        });
        _search(_searchController.text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent
              : AppColors.accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : AppColors.accent,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
