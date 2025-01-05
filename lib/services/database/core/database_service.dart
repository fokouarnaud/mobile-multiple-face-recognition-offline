// lib/services/database/core/database_service.dart

import 'package:flutterface/services/database/core/sql_statements.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

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
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.transaction((txn) async {
      await txn.execute(SqlStatements.createBoxesTable);
      await txn.execute(SqlStatements.createFacesTable);
      await txn.execute(SqlStatements.createAttendanceTable);
      await txn.execute(SqlStatements.createFaceBoxIndex);
      await txn.execute(SqlStatements.createAttendanceIndex);
    });
  }

  Future<T> runInTransaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return db.transaction(action);
  }
}