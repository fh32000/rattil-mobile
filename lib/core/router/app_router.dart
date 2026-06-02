import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/analytics_service.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/player/screens/player_screen.dart';
import '../../features/surah/screens/surah_detail_screen.dart';
import '../../features/favorites/screens/favorites_screen.dart';
import '../../features/playlists/screens/playlists_screen.dart';
import '../../features/search/screens/search_screen.dart';
import '../../features/reciter/screens/reciter_info_screen.dart';
import '../../features/about/screens/about_screen.dart';
import '../../features/support/screens/support_screen.dart';
import '../../features/arabic_alphabet/screens/arabic_alphabet_screen.dart';
import '../../features/arabic_alphabet/screens/letter_detail_screen.dart';
import '../../features/updates/screens/updates_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  observers: [_AnalyticsObserver()],
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/surah/:surahNumber',
      name: 'surah-detail',
      builder: (context, state) {
        final surahNumber = int.parse(
          state.pathParameters['surahNumber'] ?? '78',
        );
        return SurahDetailScreen(surahNumber: surahNumber);
      },
    ),
    GoRoute(
      path: '/player',
      name: 'player',
      pageBuilder: (context, state) => CustomTransitionPage(
        child: const PlayerScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/favorites',
      name: 'favorites',
      builder: (context, state) => const FavoritesScreen(),
    ),
    GoRoute(
      path: '/playlists',
      name: 'playlists',
      builder: (context, state) => const PlaylistsScreen(),
    ),
    GoRoute(
      path: '/search',
      name: 'search',
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/reciter',
      name: 'reciter',
      builder: (context, state) => const ReciterInfoScreen(),
    ),
    GoRoute(
      path: '/about',
      name: 'about',
      builder: (context, state) => const AboutScreen(),
    ),
    GoRoute(
      path: '/support',
      name: 'support',
      builder: (context, state) => const SupportScreen(),
    ),
    GoRoute(
      path: '/arabic-alphabet',
      name: 'arabic-alphabet',
      builder: (context, state) => const ArabicAlphabetScreen(),
    ),
    GoRoute(
      path: '/arabic-alphabet/:number',
      name: 'arabic-alphabet-letter',
      builder: (context, state) {
        final number = int.tryParse(state.pathParameters['number'] ?? '1') ?? 1;
        return LetterDetailScreen(letterNumber: number);
      },
    ),
    GoRoute(
      path: '/updates',
      name: 'updates',
      builder: (context, state) => const UpdatesScreen(),
    ),
  ],
);

class _AnalyticsObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    final name = route.settings.name;
    if (name != null) {
      AnalyticsService.instance.trackScreenView(name);
    }
  }
}
