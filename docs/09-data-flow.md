# 09 Data Flow

The app follows a **unidirectional data flow** — actions flow down, state flows up.

## Generic Data Flow

```
[ User Action ]
      │ tap, swipe, button press
      ▼
[ Widget ]
      │ calls ref.read(provider.notifier).method()
      ▼
[ StateNotifier / Service ]
      │ delegates to repository
      ▼
[ Repository ]
      │ reads/writes
      ▼
[ Data Source ]
      │ Hive box / Static data
      ▼
[ State Update ]
      │ state = newValue / stream emits
      ▼
[ UI Rebuild ]
      │ ref.watch() triggers build()
```

---

## Flow 1: Playing a Surah (from HomeScreen)

```
User taps play button on "سورة النبأ" (index 1)
  │
  ▼
SurahListTile.onPlay()
  │
  ▼
HomeScreen: handler.loadTracks(JuzAmmaData.tracks, startIndex: 1)
  │
  ▼
QuranAudioHandler.loadTracks()
  ├── _trackList.add(all 38 tracks)
  ├── _currentIndex.add(1)
  ├── queue.add(mediaItems)         ← AudioService notification
  └── _loadCurrentTrack()
        │
        ▼
      AudioPlayer.setAsset('assets/audio/juz_amma/078-an-naba.mp3')
      AudioPlayer.seek(savedPosition)  ← from Hive
      AudioPlayer.play()
        │
        ▼
      playbackEventStream emits → _transformEvent()
        │
        ▼
      playbackState stream → isPlayingProvider → UI rebuilds
      positionStream (every 200ms) → positionProvider → MiniPlayer updates
```

---

## Flow 2: Favorites Toggle

```
User taps heart icon on PlayerScreen
  │
  ▼
ref.read(favoritesProvider.notifier).toggle(track.id)
  │
  ▼
FavoritesNotifier.toggle(id)
  ├── FavoritesRepository.toggleFavorite(id)
  │     ├── _getFavorites() → HiveService.favoritesBox.get('favorite_tracks')
  │     ├── toggle logic (add/remove)
  │     └── _saveFavorites() → HiveService.favoritesBox.put('favorite_tracks', list)
  └── state = _repo.getAllFavorites().toSet()   ← triggers UI rebuild
        │
        ▼
      All widgets watching favoritesProvider rebuild
      (PlayerScreen, SurahDetailScreen, FavoritesScreen)
```

---

## Flow 3: Playback Position Persistence

```
AudioPlayer is playing
  │
  ▼
QuranAudioHandler constructor:
  _player.positionStream
    .throttleTime(Duration(seconds: 3))
    .listen((_) => _saveCurrentPosition())
  │
  ▼
_saveCurrentPosition()
  │
  ▼
PlaybackRepository.savePosition(track.id, position.inMilliseconds)
  │
  ▼
HiveService.playbackBox.put(track.id, positionMs)
  │
  ▼  (when track is loaded again)
_loadCurrentTrack()
  ├── savedPosition = _playbackRepo.getPosition(track.id)
  └── _player.seek(Duration(milliseconds: savedPosition))
```

---

## Flow 4: Alphabet Letter Playback

```
User taps play on LetterCard (letter #5, Jeem)
  │
  ▼
ArabicAlphabetScreen._playLetter(letter)
  │
  ▼
handler.loadLetterTracks(
  letterTracks: ArabicAlphabetData.toAudioTracks(),  // 28 AudioTracks
  startIndex: 4,                                     // 0-based = letter #5
)
  │
  ▼
QuranAudioHandler.loadLetterTracks()
  ├── _trackList.add(all 28 letter tracks)
  ├── _currentIndex.add(4)
  ├── queue.add(mediaItems)
  ├── mediaItem.add(current track)
  └── _player.setAsset('assets/audio/arabic_alphabet/005-jeem.mp3')
      _player.play()
```

---

## Flow 5: Playlist Play

```
User taps play on playlist item
  │
  ▼
playlists_screen.dart:
  final playlistTracks = playlist.trackIds.map(id =>
    allTracks.firstWhere(t => t.id == id)
  ).toList();
  handler.loadTracks(playlistTracks, startIndex: 0);
  │
  ▼
(Same as Flow 1 from loadTracks onward)
```

---

## Flow 6: Update Check

```
HomeScreen.initState()
  │
  ▼
ref.read(updateProvider.notifier).checkForUpdates(isSilent: true)
  │
  ▼
UpdateNotifier.checkForUpdates()
  ├── Checks Hive for last check date (skip if today)
  ├── PackageInfo.fromPlatform() → current version
  ├── UpdateService.fetchLatestVersion() → http.get(versionCheckUrl)
  ├── Compares version strings (semver + build number)
  └── state = UpdateState(status: updateAvailable, ...)
        │
        ▼
      HomeScreen listens: shows SnackBar "تحديث جديد متاح!" → tap → /updates
```

---

---

## Flow 7: Hifz Memorization — Enabling Mode

```
User taps Hifz toggle on PlayerScreen
  │
  ▼
ref.read(audioHandlerProvider).enableHifzMode()
  │
  ▼
QuranAudioHandler.enableHifzMode()
  ├── _savedTrackList = List.from(_trackList.value)        // save legacy state
  ├── _savedTrackIndex = _currentIndex.value
  ├── _hifzMode = true
  ├── _ayahTracks = AyahTrackSource.getAyahTracks(surahNumber) // 585files total
  ├── _trackList.add(_ayahTracks)                          // replace playlist
  ├── _currentIndex.add(0)
  ├── _memState = MemorizationPlaybackState(currentAyah:1, …)
  └── await _playAyah(1)
        │
        ▼
      _playAyah(1)
        ├── _player.setAudioSource(AudioLoader.createSource(assetPath))
        ├── _player.setSpeed(settings.playbackSpeed)
        ├── _player.setVolume(settings.volume)
        └── _player.play()
              │
              ▼
            PlaybackEventStream emits → _transformEvent()
              │
              ▼
            playbackState → isPlayingProvider → UI
            positionStream → positionProvider  → UI (countdown, progress)
```

---

## Flow 8: Hifz Memorization — Ayah Completion Cycle

```
Audio finishes playing ayah N (repetition R)
  │
  ▼
processingStateStream emits ProcessingState.completed
  │
  ▼
_onTrackCompleted()
  │  (if _hifzMode)
  ▼
_handleAyahCompleted()
  │
  ├── _resolveDuration() → ayahDuration
  │
  ├── Determine effective repCount:
  │     surahNumber = _ayahTracks.first.surahNumber
  │     isBasmala = (surahNumber != 1 && currentAyah == 1)
  │     repCount = isBasmala ? 1 : _memSettings.ayahRepeatCount
  │
  ├── if (nextRep < repCount):
  │     _memState.copyWith(currentRepetition: nextRep)
  │     _scheduleNextPlayback(() => _playAyah(currentAyah))
  │       │
  │       ▼  (if pauseForRecitation)
  │     _player.pause()
  │     _memState.phase = HifzPhase.reciting
  │     Timer(ayahDuration / speed × multiplier) {
  │       _memState.phase = HifzPhase.listening
  │       _playAyah(currentAyah)  // replay same ayah
  │     }
  │
  ├── else (last repetition):
  │     if (nextAyah <= _ayahTracks.length):
  │       _scheduleNextPlayback(() async {
  │         _memState.copyWith(currentAyah: nextAyah, curRep:0)
  │         await _playAyah(nextAyah)
  │       })
  │
  └── else (surah complete):
        _handleSurahComplete()
          ├── if (repeatSurah):
          │     _memState.copyWith(curAyah:1, curRep:0)
          │     _playAyah(1)
          └── else:
                _disableHifzMode()
                _player.stop()
                _trackList.add(_savedTrackList)
                _currentIndex.add(_savedTrackIndex + 1)
```

---

## Flow 9: Memorization Settings Persistence

```
User changes ayah repeat count (3 → 5) on PlayerScreen
  │
  ▼
ref.read(audioHandlerProvider).updateMemorizationSettings(newSettings)
  │
  ▼
QuranAudioHandler.updateMemorizationSettings(settings)
  ├── _memSettings = settings
  ├── _memSettingsSubject.add(settings)      // triggers UI rebuild
  ├── _memSettingsRepo.save(settings)
  │     │
  │     ▼
  │   MemorizationSettingsRepository.save()
  │     ├── json = jsonEncode(settings.toMap())
  │     └── HiveService.settingsBox.put('hifz_settings', json)
  │
  ├── if (speedChanged) _player.setSpeed(settings.playbackSpeed)
  └── if (volumeChanged) _player.setVolume(settings.volume)
```

---

## Flow 10: Verse Display in Hifz Mode

```
Memorization state changes (new ayah)
  │
  ▼
memorizationPlaybackStateProvider emits new state
  │
  ▼
VerseDisplayWidget rebuilds
  │
  ├── Reads currentAyah, phase from memorizationPlaybackStateProvider
  ├── Reads hideVerses from memorizationSettingsProvider
  │
  ├── If hideVerses == false:
  │     ├── currentAyahText = VerseService.instance.getVerse(surah, currentAyah)
  │     ├── prevAyahText    = VerseService.instance.getVerse(surah, currentAyah - 1)
  │     └── nextAyahText    = VerseService.instance.getVerse(surah, currentAyah + 1)
  │
  └── If hideVerses == true:
        ├── phase == listening → "👂 استمع للآية"
        └── phase == reciting  → "👄 ردد الآية الآن"
```

---

## Data Source Summary

| Data | Type | Location |
| :--- | :--- | :--- |
| Surah list | Static constant | `JuzAmmaData.surahs` |
| Audio tracks | Computed from surahs | `JuzAmmaData.tracks` |
| Ayah track file counts | Static constant | `AyahTrackSource.ayahFileCounts` |
| Ayah→verse mapping | Computed | `ayahFileToVerseNumber()` |
| Quran verse text | Package (quran) | `VerseService` → `quran.getVerse()` |
| Alphabet letters | Static constant | `ArabicAlphabetData.letters` |
| Favorites | Hive Box (List<String>) | `favorites` box, key `favorite_tracks` |
| Playlists | Hive Box (JSON string) | `playlists` box, key = playlist ID |
| Playback positions | Hive Box (int ms) | `playback_positions` box, key = track ID |
| Memorization settings | Hive Box (JSON string) | `settings` box, key `hifz_settings` |
| Settings (update check) | Hive Box | `settings` box |
| App version | Remote HTTP JSON | `https://woostore.dev/apps/rattil/version.json` |
