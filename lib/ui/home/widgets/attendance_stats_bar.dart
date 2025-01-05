import 'package:flutter/material.dart';
import 'package:flutterface/models/attendance_stats.dart';
import 'package:flutterface/ui/home/providers/face_detection_provider.dart';
import 'package:provider/provider.dart';

class AttendanceStatsBar extends StatelessWidget {
  const AttendanceStatsBar({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = context.select<FaceDetectionProvider, AttendanceStats?>(
          (provider) => provider.attendanceStats,
    );

    if (stats == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatChip(
            context,
            'Total',
            stats.totalRegistered,
            Icons.people_outline,
          ),
          _buildStatChip(
            context,
            'Present',
            stats.present,
            Icons.check_circle_outline,
            color: Colors.green,
          ),
          _buildStatChip(
            context,
            'Absent',
            stats.absent,
            Icons.cancel_outlined,
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(
      BuildContext context,
      String label,
      int value,
      IconData icon, {
        Color? color,
      }) {
    final theme = Theme.of(context);
    color ??= theme.colorScheme.primary;

    return Chip(
      avatar: Icon(icon, color: color, size: 18),
      label: Text(
        '$label: $value',
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color.withAlpha(25),
    );
  }
}
