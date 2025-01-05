
import 'dart:convert';
import 'package:flutterface/models/face_match.dart';
import 'package:flutterface/models/face_record.dart';
import 'package:flutterface/services/database/core/database_service.dart';
import 'package:flutterface/services/database/utils/cosine_similarity.dart';

class FaceRepository {
  final DatabaseService _db = DatabaseService.instance;
  static const double similarityThreshold = 0.6;

  Future<int> getFaceCount(int boxId) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM faces WHERE box_id = ?',
      [boxId],
    );
    return result.first['count'] as int;
  }

  Future<bool> deleteAllFaces(int boxId) async {
    try {
      final db = await _db.database;
      await db.delete(
        'faces',
        where: 'box_id = ?',
        whereArgs: [boxId],
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<FaceRecord>> getFacesByBoxId(int boxId) async {
    final db = await _db.database;
    final results = await db.query(
      'faces',
      where: 'box_id = ?',
      whereArgs: [boxId],
      orderBy: 'name ASC',
    );

    return results.map((map) => FaceRecord.fromMap(map)).toList();
  }

  Future<void> saveFaceRecord(FaceRecord record) async {
    final db = await _db.database;
    final recordMap = record.toMap();
    recordMap['updated_at'] = DateTime.now().toIso8601String();
    await db.insert('faces', recordMap);
  }

  Future<void> deleteFaceRecord(int id) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      // Delete the face record
      await txn.delete(
        'faces',
        where: 'id = ?',
        whereArgs: [id],
      );

      // Also delete any related attendance records
      await txn.delete(
        'attendance',
        where: 'face_id = ?',
        whereArgs: [id],
      );
    });
  }

  Future<bool> updateFaceRecord(FaceRecord record) async {
    if (record.id == null) return false;

    final db = await _db.database;
    final recordMap = record.toMap();
    recordMap['updated_at'] = DateTime.now().toIso8601String();

    final rowsAffected = await db.update(
      'faces',
      recordMap,
      where: 'id = ?',
      whereArgs: [record.id],
    );

    return rowsAffected > 0;
  }

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
}