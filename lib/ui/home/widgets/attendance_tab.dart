// lib/ui/home/widgets/attendance_tab.dart

import 'package:flutter/material.dart';
import 'package:flutterface/models/attendance_stats.dart';
import 'package:flutterface/ui/home/providers/face_detection_provider.dart';
import 'package:provider/provider.dart';

class AttendanceTab extends StatelessWidget {
  const AttendanceTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FaceDetectionProvider>();
    final stats = provider.attendanceStats;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsCards(context, stats),
          const SizedBox(height: 16),
          Expanded(
            child: _buildAttendanceLists(context, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, AttendanceStats? stats) {
    if (stats == null) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Present',
            stats.present,
            stats.totalRegistered,
            Icons.check_circle_outline,
            Colors.green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            context,
            'Absent',
            stats.absent,
            stats.totalRegistered,
            Icons.cancel_outlined,
            Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      BuildContext context,
      String label,
      int value,
      int total,
      IconData icon,
      Color color,
      ) {
    final theme = Theme.of(context);
    final percentage = total > 0 ? (value / total * 100).round() : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: theme.textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: total > 0 ? value / total : 0,
              backgroundColor: color.withAlpha(25),
              valueColor: AlwaysStoppedAnimation(color),
            ),
            const SizedBox(height: 4),
            Text(
              '$percentage%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withAlpha(178),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceLists(BuildContext context, FaceDetectionProvider provider) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withAlpha(178),
            tabs: const [
              Tab(text: 'Absent'),
              Tab(text: 'Present'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildAbsentList(context, provider),
                _buildPresentList(context, provider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbsentList(BuildContext context, FaceDetectionProvider provider) {
    final absentFaces = provider.absentFaces;

    if (absentFaces.isEmpty) {
      return _buildEmptyListMessage('No absent faces');
    }

    return ListView.builder(
      itemCount: absentFaces.length,
      itemBuilder: (context, index) {
        final face = absentFaces[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: MemoryImage(face.alignedImage),
          ),
          title: Text(face.name ?? 'Unknown'),
          trailing: const Icon(Icons.cancel_outlined, color: Colors.red),
        );
      },
    );
  }

  Widget _buildPresentList(BuildContext context, FaceDetectionProvider provider) {
    final presentFaces = provider.presentFaces;

    if (presentFaces.isEmpty) {
      return _buildEmptyListMessage('No present faces');
    }

    return ListView.builder(
      itemCount: presentFaces.length,
      itemBuilder: (context, index) {
        final face = presentFaces[index];
        final similarity = (face.similarity ?? 0) * 100;

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: MemoryImage(face.alignedImage),
          ),
          title: Text(face.name ?? 'Unknown'),
          subtitle: LinearProgressIndicator(
            value: face.similarity ?? 0,
            backgroundColor: Colors.green.withAlpha(25),
            valueColor: const AlwaysStoppedAnimation(Colors.green),
          ),
          trailing: Text(
            '${similarity.toStringAsFixed(1)}%',
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyListMessage(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off_outlined,
            size: 48,
            color: Colors.grey.withAlpha(127),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey.withAlpha(178),
            ),
          ),
        ],
      ),
    );
  }
}