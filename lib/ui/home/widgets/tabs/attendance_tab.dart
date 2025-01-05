import 'package:flutter/material.dart';
import 'package:flutterface/models/attendance_stats.dart';
import 'package:flutterface/ui/home/providers/face_detection_provider.dart';
import 'package:provider/provider.dart';

class AttendanceTabContent extends StatelessWidget {
  const AttendanceTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FaceDetectionProvider>();
    final stats = provider.attendanceStats;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (stats != null) ...[
              _buildStatsCards(context, stats),
              const SizedBox(height: 16),
            ],
            _buildAttendanceList(context, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, AttendanceStats stats) {
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          if (total > 0) ...[
            LinearProgressIndicator(
              value: value / total,
              backgroundColor: color.withAlpha(25),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAttendanceList(BuildContext context, FaceDetectionProvider provider) {
    return DefaultTabController(
      length: 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TabBar(
            tabs: const [
              Tab(text: 'Present'),
              Tab(text: 'Absent'),
            ],
            labelColor: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(
            height: 200, // Fixed height for list
            child: TabBarView(
              children: [
                _buildPresentList(provider),
                _buildAbsentList(provider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresentList(FaceDetectionProvider provider) {
    return ListView.builder(
      itemCount: provider.presentFaces.length,
      itemBuilder: (context, index) {
        final face = provider.presentFaces[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: MemoryImage(face.alignedImage),
          ),
          title: Text(face.name ?? 'Unknown'),
          trailing: Text(
            '${((face.similarity ?? 0) * 100).toStringAsFixed(1)}%',
            style: const TextStyle(color: Colors.green),
          ),
        );
      },
    );
  }

  Widget _buildAbsentList(FaceDetectionProvider provider) {
    return ListView.builder(
      itemCount: provider.absentFaces.length,
      itemBuilder: (context, index) {
        final face = provider.absentFaces[index];
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
}