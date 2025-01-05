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
      image_hash TEXT NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      FOREIGN KEY (box_id) REFERENCES boxes (id) ON DELETE CASCADE
    )
  ''';

  static const String createAttendanceTable = '''
    CREATE TABLE attendance(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      face_id INTEGER NOT NULL,
      timestamp TEXT NOT NULL,
      period INTEGER NOT NULL,
      similarity REAL NOT NULL,
      detected_image_hash TEXT NOT NULL,
      FOREIGN KEY (face_id) REFERENCES faces (id) ON DELETE CASCADE
    )
  ''';

  // Indexes
  static const String createFaceBoxIndex =
      'CREATE INDEX idx_faces_box ON faces(box_id)';

  static const String createAttendanceIndex =
      'CREATE INDEX idx_attendance_composite ON attendance(face_id, timestamp, period)';
}