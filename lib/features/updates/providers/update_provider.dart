import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/update_service.dart';
import '../../../data/models/app_version.dart';

enum UpdateStatus { initial, checking, updateAvailable, upToDate, error }

class UpdateState {
  final UpdateStatus status;
  final AppVersion? latestVersion;
  final String currentVersionStr;

  UpdateState({
    this.status = UpdateStatus.initial,
    this.latestVersion,
    this.currentVersionStr = '',
  });

  UpdateState copyWith({
    UpdateStatus? status,
    AppVersion? latestVersion,
    String? currentVersionStr,
  }) {
    return UpdateState(
      status: status ?? this.status,
      latestVersion: latestVersion ?? this.latestVersion,
      currentVersionStr: currentVersionStr ?? this.currentVersionStr,
    );
  }
}

final updateProvider = StateNotifierProvider<UpdateNotifier, UpdateState>((
  ref,
) {
  return UpdateNotifier(UpdateService());
});

class UpdateNotifier extends StateNotifier<UpdateState> {
  final UpdateService _updateService;

  UpdateNotifier(this._updateService) : super(UpdateState());

  Future<void> checkForUpdates({bool isSilent = false}) async {
    if (!isSilent) {
      state = state.copyWith(status: UpdateStatus.checking);
    }

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersionStr = packageInfo.version;
      final currentBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 0;

      if (!isSilent) {
        state = state.copyWith(
          currentVersionStr: '$currentVersionStr+$currentBuildNumber',
        );
      }

      // Check if silent check was already done today
      if (isSilent) {
        final box = Hive.box(AppConstants.settingsBox);
        final lastCheckStr = box.get('last_update_check');
        if (lastCheckStr != null) {
          final lastCheck = DateTime.parse(lastCheckStr);
          final now = DateTime.now();
          if (now.difference(lastCheck).inDays == 0 &&
              now.day == lastCheck.day) {
            // Already checked today, skip silent check
            return;
          }
        }
      }

      final latestAppVersion = await _updateService.fetchLatestVersion();

      if (latestAppVersion != null) {
        if (isSilent) {
          final box = Hive.box(AppConstants.settingsBox);
          box.put('last_update_check', DateTime.now().toIso8601String());
        }

        // Compare versions
        bool hasUpdate = false;

        final currentParts = currentVersionStr
            .split('.')
            .map((e) => int.tryParse(e) ?? 0)
            .toList();
        final latestParts = latestAppVersion.latestVersion
            .split('.')
            .map((e) => int.tryParse(e) ?? 0)
            .toList();

        // Pad with zeros if lengths differ (e.g. 1.0 vs 1.0.1)
        while (currentParts.length < 3) {
          currentParts.add(0);
        }
        while (latestParts.length < 3) {
          latestParts.add(0);
        }

        for (int i = 0; i < 3; i++) {
          if (latestParts[i] > currentParts[i]) {
            hasUpdate = true;
            break;
          } else if (latestParts[i] < currentParts[i]) {
            break; // Current is newer (e.g., development build)
          }
        }

        // If versions are same, check build number
        if (!hasUpdate &&
            currentParts[0] == latestParts[0] &&
            currentParts[1] == latestParts[1] &&
            currentParts[2] == latestParts[2]) {
          if (latestAppVersion.buildNumber > currentBuildNumber) {
            hasUpdate = true;
          }
        }

        if (hasUpdate) {
          state = state.copyWith(
            status: UpdateStatus.updateAvailable,
            latestVersion: latestAppVersion,
            currentVersionStr: '$currentVersionStr+$currentBuildNumber',
          );
        } else {
          state = state.copyWith(
            status: UpdateStatus.upToDate,
            currentVersionStr: '$currentVersionStr+$currentBuildNumber',
          );
        }
      } else {
        if (!isSilent) {
          state = state.copyWith(
            status: UpdateStatus.error,
            currentVersionStr: '$currentVersionStr+$currentBuildNumber',
          );
        }
      }
    } catch (e) {
      if (!isSilent) {
        state = state.copyWith(status: UpdateStatus.error);
      }
    }
  }
}
