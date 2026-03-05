class Playlist {
  final String id;
  final String name;
  final List<String> trackIds;
  final DateTime createdAt;

  Playlist({
    required this.id,
    required this.name,
    required this.trackIds,
    required this.createdAt,
  });

  Playlist copyWith({
    String? name,
    List<String>? trackIds,
  }) {
    return Playlist(
      id: id,
      name: name ?? this.name,
      trackIds: trackIds ?? this.trackIds,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'trackIds': trackIds,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Playlist.fromJson(Map<String, dynamic> json) => Playlist(
        id: json['id'] as String,
        name: json['name'] as String,
        trackIds: List<String>.from(json['trackIds'] as List),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
