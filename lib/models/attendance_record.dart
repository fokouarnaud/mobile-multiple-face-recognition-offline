class AttendanceRecord {
  final int id;
  final int faceId;
  final DateTime timestamp;
  final int period;
  final double similarity;
  final String detectedImageHash;

  const AttendanceRecord({
    required this.id,
    required this.faceId,
    required this.timestamp,
    required this.period,
    required this.similarity,
    required this.detectedImageHash,
  });

  Map<String, dynamic> toMap() {
    return {
      'face_id': faceId,
      'timestamp': timestamp.toIso8601String(),
      'period': period,
      'similarity': similarity,
      'detected_image_hash': detectedImageHash,
    };
  }

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      id: map['id'] as int,
      faceId: map['face_id'] as int,
      timestamp: DateTime.parse(map['timestamp'] as String),
      period: map['period'] as int,
      similarity: map['similarity'] as double,
      detectedImageHash: map['detected_image_hash'] as String,
    );
  }
}