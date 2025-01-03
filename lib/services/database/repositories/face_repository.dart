import 'dart:convert';

import 'package:flutterface/models/face_record.dart';
import 'package:flutterface/services/database/core/database_service.dart';
import 'package:flutterface/services/database/models/face_match.dart';
import 'package:flutterface/services/database/utils/cosine_similarity.dart';

class FaceRepository {
  final DatabaseService _db = DatabaseService.instance;
  static const double similarityThreshold = 0.6;

  Future<FaceMatch?> findMatchingFace(List<double> embedding) async {
    final db = await _db.database;
    final existingFaces = await db.query('faces');

    FaceMatch? bestMatch;
    double highestSimilarity = similarityThreshold;

    for (final face in existingFaces) {
      final existingEmbedding = List<double>.from(
        jsonDecode(face['embedding'] as String),
      );
      final similarity = CosineSimilarity.calculate(embedding, existingEmbedding);
      if (similarity >= highestSimilarity) {
        highestSimilarity = similarity;
        bestMatch = FaceMatch(
          id: face['id'] as int,
          name: face['name'] as String,
          imageHash: face['image_hash'] as String,
          similarity: similarity,
        );
      }
    }
    return bestMatch;
  }

  Future<FaceRecord?> getFaceById(int id) async {
    final db = await _db.database;
    final results = await db.query(
      'faces',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return FaceRecord.fromMap(results.first);
  }

  Future<void> saveFaceRecord(FaceRecord record) async {
    final db = await _db.database;
    final recordMap = record.toMap();
    recordMap['updated_at'] = DateTime.now().toIso8601String();
    await db.insert('faces', recordMap);
  }
}