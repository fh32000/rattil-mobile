import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/surah/:surahNumber',
      builder: (context, state) {
        final surahNumber = int.parse(
          state.pathParameters['surahNumber'] ?? '78',
        );
        return SurahDetailScreen(surahNumber: surahNumber);
      },
    ),
    GoRoute(
      path: '/player',
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
      builder: (context, state) => const FavoritesScreen(),
    ),
    GoRoute(
      path: '/playlists',
      builder: (context, state) => const PlaylistsScreen(),
    ),
    GoRoute(path: '/search', builder: (context, state) => const SearchScreen()),
    GoRoute(
      path: '/reciter',
      builder: (context, state) => const ReciterInfoScreen(),
    ),
    GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
    GoRoute(
      path: '/support',
      builder: (context, state) => const SupportScreen(),
    ),
    GoRoute(
      path: '/arabic-alphabet',
      builder: (context, state) => const ArabicAlphabetScreen(),
    ),
    GoRoute(
      path: '/arabic-alphabet/:number',
      builder: (context, state) {
        final number = int.tryParse(state.pathParameters['number'] ?? '1') ?? 1;
        return LetterDetailScreen(letterNumber: number);
      },
    ),
    GoRoute(
      path: '/updates',
      builder: (context, state) => const UpdatesScreen(),
    ),
  ],
);
