# 06 Routing

Warattilhu uses **Go Router** for all navigation, defined in a single file.

## Router File

`lib/core/router/app_router.dart`

```dart
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [ /* 12 routes */ ],
);
```

## Route Table

| Path | Screen | Parameters |
| :--- | :--- | :--- |
| `/` | `HomeScreen` | — |
| `/surah/:surahNumber` | `SurahDetailScreen` | `surahNumber` (int) |
| `/player` | `PlayerScreen` | — (slide-up transition) |
| `/favorites` | `FavoritesScreen` | — |
| `/playlists` | `PlaylistsScreen` | — |
| `/search` | `SearchScreen` | — |
| `/reciter` | `ReciterInfoScreen` | — |
| `/about` | `AboutScreen` | — |
| `/support` | `SupportScreen` | — |
| `/arabic-alphabet` | `ArabicAlphabetScreen` | — |
| `/arabic-alphabet/:number` | `LetterDetailScreen` | `number` (int, 1-28) |
| `/updates` | `UpdatesScreen` | — |

## Navigation Flow Diagram

```
Drawer / Quick Actions
      │
      ▼
┌───────────┐     ┌──────────────────┐
│   Home    │────▶│   SurahDetail    │
│   (/)     │     │  (/surah/:num)   │
└─────┬─────┘     └──────────────────┘
      │
      ├─────────────────────────┐
      │ MiniPlayer tap          │
      ▼                         ▼
┌───────────┐          ┌───────────────┐
│  Player   │          │   Search      │
│  (/player)│          │  (/search)    │
└───────────┘          └───────────────┘
      │
      ├── /favorites  ───▶ FavoritesScreen
      ├── /playlists  ───▶ PlaylistsScreen
      ├── /reciter    ───▶ ReciterInfoScreen
      ├── /about      ───▶ AboutScreen
      ├── /support    ───▶ SupportScreen
      ├── /arabic-alphabet    ───▶ ArabicAlphabetScreen
      │      └── /arabic-alphabet/:num ───▶ LetterDetailScreen
      └── /updates    ───▶ UpdatesScreen
```

## Navigation Method Used

- `context.push('/path')` — used for most navigation (adds to stack)
- `Navigator.pop(context)` — used in AppBar back buttons
- `context.go('/path')` — available but not used (all routes use `push`)
- `CustomTransitionPage` — only used for `/player` route (slide-up animation)

## Deep Linking

Not implemented. All routes are internal only.

## Route Parameters

```dart
// Surah detail: /surah/78
final surahNumber = int.parse(
  state.pathParameters['surahNumber'] ?? '78',
);

// Letter detail: /arabic-alphabet/5
final number = int.tryParse(state.pathParameters['number'] ?? '1') ?? 1;
```

## Router Pattern

The app uses `MaterialApp.router`:

```dart
MaterialApp.router(
  routerConfig: appRouter,   // ← GoRouter instance
  // ...
  builder: (context, child) {
    return Directionality(
      textDirection: TextDirection.rtl,  // ← Force RTL for entire app
      child: child ?? const SizedBox.shrink(),
    );
  },
);
```

## Adding a New Route

1. Import the screen in `app_router.dart`
2. Add a `GoRoute` to the `routes` list
3. Navigate with `context.push('/your-path')`
