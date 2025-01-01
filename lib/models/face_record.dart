import 'dart:convert';

class FaceRecord {
  final int? id;
  final List<double> embedding;
  final DateTime createdAt;
  final String imageHash;

  FaceRecord({
    this.id,
    required this.embedding,
    required this.createdAt,
    required this.imageHash,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'embedding': jsonEncode(embedding),
      'created_at': createdAt.toIso8601String(),
      'image_hash': imageHash,
    };
  }

  factory FaceRecord.fromMap(Map<String, dynamic> map) {
    return FaceRecord(
      id: map['id'],
      embedding: List<double>.from(jsonDecode(map['embedding'])),
      createdAt: DateTime.parse(map['created_at']),
      imageHash: map['image_hash'],
    );
  }
}
