import 'dart:convert';
import 'dart:math';

import 'package:flutterface/models/face_record.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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

  Future<bool> isFaceExists(List<double> embedding) async {
    const double similarityThreshold = 0.6;
    final db = await database;
    final existingFaces = await db.query('faces');

    for (final face in existingFaces) {
      final existingEmbedding = List<double>.from(
        jsonDecode(face['embedding'] as String),
      );
      final similarity = _calculateCosineSimilarity(embedding, existingEmbedding);
      if (similarity >= similarityThreshold) {
        return true;
      }
    }
    return false;
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

  Future<void> saveFaceRecord(FaceRecord record) async {
    final db = await database;
    await db.insert('faces', record.toMap());
  }
}
