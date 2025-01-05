import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class FaceRecord {
  final int? id;
  final String name;
  final int boxId;
  final List<double> embedding;
  final String imageHash;
  final DateTime createdAt;

  FaceRecord({
    this.id,
    required this.name,
    required this.boxId,
    required this.embedding,
    required this.imageHash,
    required this.createdAt,
  });

  // Get aligned image from hash
  Uint8List get alignedImage => base64Decode(imageHash);

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'box_id': boxId,
      'embedding': jsonEncode(embedding),
      'image_hash': imageHash,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory FaceRecord.fromMap(Map<String, dynamic> map) {
    return FaceRecord(
      id: map['id'] as int?,
      name: map['name'] as String,
      boxId: map['box_id'] as int,
      embedding: List<double>.from(jsonDecode(map['embedding'] as String)),
      imageHash: map['image_hash'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}