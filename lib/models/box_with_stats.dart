class BoxWithStats {
  final int id;
  final String name;
  final String description;
  final int faceCount;
  final DateTime lastUpdated;
  final DateTime createdAt;

  BoxWithStats({
    required this.id,
    required this.name,
    required this.description,
    required this.faceCount,
    required this.lastUpdated,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'face_count': faceCount,
      'last_updated': lastUpdated.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory BoxWithStats.fromMap(Map<String, dynamic> map) {
    return BoxWithStats(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      faceCount: map['face_count'],
      lastUpdated: DateTime.parse(map['last_updated']),
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}