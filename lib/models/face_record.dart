import 'dart:convert';

class FaceRecord {
  final int? id;
  final String name;
  final int boxId;
  final List<double> embedding;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String imageHash;

  FaceRecord({
    this.id,
    required this.name,
    required this.boxId,
    required this.embedding,
    required this.createdAt,
    DateTime? updatedAt,
    required this.imageHash,
  }) : updatedAt = updatedAt ?? createdAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'box_id': boxId,
      'embedding': jsonEncode(embedding),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'image_hash': imageHash,
    };
  }

  factory FaceRecord.fromMap(Map<String, dynamic> map) {
    return FaceRecord(
      id: map['id'],
      name: map['name'],
      boxId: map['box_id'],
      embedding: List<double>.from(jsonDecode(map['embedding'])),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      imageHash: map['image_hash'],
    );
  }
}