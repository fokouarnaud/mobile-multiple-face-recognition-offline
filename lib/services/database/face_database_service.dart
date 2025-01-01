import 'dart:convert';
import 'dart:math';

import 'package:flutterface/models/face_record.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class FaceMatch {
  final int id;
  final String name;
  final String imageHash;
  final double similarity;

  FaceMatch({
    required this.id,
    required this.name,
    required this.imageHash,
    required this.similarity,
  });
}

class FaceDatabaseService {
  static final FaceDatabaseService instance = FaceDatabaseService._init();
  static Database? _database;

  FaceDatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initializeDB();
    return _database!;
  }

  Future<Database> _initializeDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'faces.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          '''
          CREATE TABLE faces(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            embedding TEXT NOT NULL,
            created_at TEXT NOT NULL,
            image_hash TEXT NOT NULL
          )
          ''',
        );
        await db.execute('CREATE INDEX idx_image_hash ON faces(image_hash)');
      },
    );
  }

  Future<FaceMatch?> findMatchingFace(List<double> embedding) async {
    const double similarityThreshold = 0.6;
    final db = await database;
    final existingFaces = await db.query('faces');

    FaceMatch? bestMatch;
    double highestSimilarity = similarityThreshold;

    for (final face in existingFaces) {
      final existingEmbedding = List<double>.from(
        jsonDecode(face['embedding'] as String),
      );
      final similarity = _calculateCosineSimilarity(embedding, existingEmbedding);
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

  double _calculateCosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) return 0.0;

    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    return dotProduct / (sqrt(normA) * sqrt(normB));
  }

  Future<FaceRecord?> getFaceById(int id) async {
    final db = await database;
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
    final db = await database;
    await db.insert('faces', record.toMap());
  }
}