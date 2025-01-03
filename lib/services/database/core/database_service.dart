
import 'package:flutterface/services/database/core/sql_statements.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init(); // Private constructor

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
        await db.execute(SqlStatements.createBoxesTable);
        await db.execute(SqlStatements.createFacesTable);
        await db.execute(SqlStatements.createImageHashIndex);
        await db.execute(SqlStatements.createBoxIdIndex);
      },
    );
  }
}

