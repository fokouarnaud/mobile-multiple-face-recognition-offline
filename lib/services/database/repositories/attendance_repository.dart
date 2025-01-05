import 'package:flutterface/models/attendance_record.dart';
import 'package:flutterface/models/attendance_stats.dart';
import 'package:flutterface/services/database/core/database_service.dart';
import 'package:sqflite/sqflite.dart';

class AttendanceRepository {
  final DatabaseService _db = DatabaseService.instance;
  static const double _similarityThreshold = 0.6;

  Future<AttendanceStats> getAttendanceStats(
    int boxId,
    int period,
    DateTime date,
  ) async {
    final db = await _db.database;

    // Get start and end of the day
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    // Get total registered faces for the box
    final totalRegistered = Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM faces WHERE box_id = ?',
            [boxId],
          ),
        ) ??
        0;

    // Get present faces (with similarity >= threshold)
    final present = Sqflite.firstIntValue(
          await db.rawQuery('''
      SELECT COUNT(DISTINCT f.id)
      FROM faces f
      JOIN attendance a ON f.id = a.face_id
      WHERE f.box_id = ?
      AND a.period = ?
      AND a.timestamp >= ?
      AND a.timestamp < ?
      AND a.similarity >= ?
    ''', [
            boxId,
            period,
            startOfDay.toIso8601String(),
            endOfDay.toIso8601String(),
            _similarityThreshold,
          ]),
        ) ??
        0;

    return AttendanceStats(
      totalRegistered: totalRegistered,
      present: present,
      absent: totalRegistered - present,
    );
  }

  Future<List<AttendanceRecord>> getAttendanceRecords(
    int boxId,
    int period,
    DateTime date,
  ) async {
    final db = await _db.database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final records = await db.rawQuery('''
      SELECT a.*
      FROM attendance a
      JOIN faces f ON a.face_id = f.id
      WHERE f.box_id = ?
      AND a.period = ?
      AND a.timestamp >= ?
      AND a.timestamp < ?
      ORDER BY a.timestamp DESC
    ''', [
      boxId,
      period,
      startOfDay.toIso8601String(),
      endOfDay.toIso8601String(),
    ]);

    return records.map((record) => AttendanceRecord.fromMap(record)).toList();
  }

  Future<void> recordAttendance(AttendanceRecord record) async {
    final db = await _db.database;
    await db.insert('attendance', record.toMap());
  }

  Future<void> recordBatchAttendance(List<AttendanceRecord> records) async {
    if (records.isEmpty) return;

    await _db.runInTransaction((txn) async {
      for (final record in records) {
        await txn.insert('attendance', record.toMap());
      }
    });
  }

  Future<bool> hasAttendanceForPeriod(
    int faceId,
    int period,
    DateTime date,
  ) async {
    final db = await _db.database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final count = Sqflite.firstIntValue(
      await db.rawQuery('''
      SELECT COUNT(*) FROM attendance
      WHERE face_id = ?
      AND period = ?
      AND timestamp >= ?
      AND timestamp < ?
    ''', [
        faceId,
        period,
        startOfDay.toIso8601String(),
        endOfDay.toIso8601String(),
      ]),
    );

    return count! > 0;
  }

  Future<void> deleteAttendanceRecords(
    int boxId,
    int period,
    DateTime date,
  ) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    await _db.runInTransaction((txn) async {
      await txn.rawDelete('''
        DELETE FROM attendance
        WHERE face_id IN (
          SELECT id FROM faces WHERE box_id = ?
        )
        AND period = ?
        AND timestamp >= ?
        AND timestamp < ?
      ''', [
        boxId,
        period,
        startOfDay.toIso8601String(),
        endOfDay.toIso8601String(),
      ]);
    });
  }
}
