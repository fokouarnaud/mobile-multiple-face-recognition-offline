class AttendanceStats {
  final int totalRegistered;
  final int present;
  final int absent;

  AttendanceStats({
    required this.totalRegistered,
    required this.present,
    required this.absent,
  });

  factory AttendanceStats.empty() {
    return AttendanceStats(
      totalRegistered: 0,
      present: 0,
      absent: 0,
    );
  }
}
