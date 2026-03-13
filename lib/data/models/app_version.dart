class AppVersion {
  final String latestVersion;
  final int buildNumber;
  final String releaseDate;
  final String updateUrl;
  final String downloadUrl;
  final String releaseNotes;
  final bool forceUpdate;

  AppVersion({
    required this.latestVersion,
    required this.buildNumber,
    required this.releaseDate,
    required this.updateUrl,
    required this.downloadUrl,
    required this.releaseNotes,
    required this.forceUpdate,
  });

  factory AppVersion.fromJson(Map<String, dynamic> json) {
    return AppVersion(
      latestVersion: json['latest_version'] ?? '1.0.0',
      buildNumber: json['build_number'] ?? 1,
      releaseDate: json['release_date'] ?? '',
      updateUrl: json['update_url'] ?? '',
      downloadUrl: json['download_url'] ?? '',
      releaseNotes: json['release_notes'] ?? '',
      forceUpdate: json['force_update'] ?? false,
    );
  }
}
