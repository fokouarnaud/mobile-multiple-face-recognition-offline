// core/sql_statements.dart
class SqlStatements {
  static const String createBoxesTable = '''
    CREATE TABLE boxes(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      description TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      face_count INTEGER DEFAULT 0
    )
  ''';

  static const String createFacesTable = '''
    CREATE TABLE faces(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      box_id INTEGER NOT NULL,
      name TEXT NOT NULL,
      embedding TEXT NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      image_hash TEXT NOT NULL,
      FOREIGN KEY (box_id) REFERENCES boxes (id)
    )
  ''';

  static const String createImageHashIndex =
      'CREATE INDEX idx_image_hash ON faces(image_hash)';

  static const String createBoxIdIndex =
      'CREATE INDEX idx_box_id ON faces(box_id)';
}