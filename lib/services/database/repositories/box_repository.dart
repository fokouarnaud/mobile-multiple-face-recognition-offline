import 'dart:async';

import 'package:flutterface/models/box_with_stats.dart';
import 'package:flutterface/models/face_box.dart';
import 'package:flutterface/services/database/core/database_service.dart';
import 'package:sqflite/sqflite.dart';

class BoxRepository {
  final DatabaseService _db = DatabaseService.instance;

  Future<List<FaceBox>> getAllBoxes() async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query('boxes');
    return List.generate(maps.length, (i) => FaceBox.fromMap(maps[i]));
  }

  Future<FaceBox> createBox(String name, String description) async {
    final db = await _db.database;
    final now = DateTime.now().toIso8601String();
    final Map<String, dynamic> boxMap = {
      'name': name,
      'description': description,
      'created_at': now,
      'updated_at': now,
      'face_count': 0,
    };

    final id = await db.insert('boxes', boxMap);
    return FaceBox.fromMap({...boxMap, 'id': id});
  }

  Future<void> updateBoxFaceCount(int boxId) async {
    final db = await _db.database;
    final count = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM faces WHERE box_id = ?',
      [boxId],
    ),) ?? 0;

    await db.update(
      'boxes',
      {
        'face_count': count,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [boxId],
    );
  }
  Future<void> updateBox(int boxId, String name, String description) async {
    final db = await _db.database;
    await db.update(
      'boxes',
      {
        'name': name,
        'description': description,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [boxId],
    );
  }

  Future<void> deleteBox(int boxId) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      // Delete associated face records first
      await txn.delete(
        'faces',
        where: 'box_id = ?',
        whereArgs: [boxId],
      );

      // Delete the box
      await txn.delete(
        'boxes',
        where: 'id = ?',
        whereArgs: [boxId],
      );
    });
  }

  Future<void> update(
      int boxId, {
        String? name,
        String? description,
      }) async {
    final db = await _db.database;
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (name != null) updates['name'] = name;
    if (description != null) updates['description'] = description;

    await db.update(
      'boxes',
      updates,
      where: 'id = ?',
      whereArgs: [boxId],
    );
  }

  Stream<List<BoxWithStats>> getBoxesWithStats() async* {
    while (true) {
      final db = await _db.database;
      final boxes = await db.query('boxes');
      final List<BoxWithStats> boxesWithStats = [];

      for (final box in boxes) {
        final faceCount = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) FROM faces WHERE box_id = ?',
          [box['id']],
        ),) ?? 0;

        boxesWithStats.add(BoxWithStats(
          id: box['id'] as int,
          name: box['name'] as String,
          description: box['description'] as String,
          faceCount: faceCount,
          lastUpdated: DateTime.parse(box['updated_at'] as String),
          createdAt: DateTime.parse(box['created_at'] as String),
        ),);
      }

      yield boxesWithStats;
      await Future.delayed(const Duration(seconds: 2));
    }
  }
}