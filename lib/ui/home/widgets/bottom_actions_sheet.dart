// lib/ui/home/widgets/bottom_actions_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutterface/ui/home/providers/face_detection_provider.dart';
import 'package:provider/provider.dart';

enum ActionMode {
  registration,
  attendance,
}

class BottomActionsSheet extends StatelessWidget {
  final ActionMode mode;

  const BottomActionsSheet({
    super.key,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: mode == ActionMode.registration
          ? _buildRegistrationActions(context)
          : _buildAttendanceActions(context),
    );
  }

  Widget _buildRegistrationActions(BuildContext context) {
    return Consumer<FaceDetectionProvider>(
      builder: (context, provider, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (provider.imageOriginal != null)
              FilledButton.icon(
                onPressed: provider.isProcessing
                    ? null
                    : () async => provider.detectAndRegisterFaces(context),
                icon: const Icon(Icons.face),
                label: const Text('Detect Faces'),
              )
            else
              const Center(
                child: Text('Take or select a photo to start'),
              ),
            if (provider.registeredFacesCount > 0) ...[
              const SizedBox(height: 16),
              _buildRegisteredFacesCount(
                  context, provider.registeredFacesCount),
            ],
          ],
        );
      },
    );
  }

  Widget _buildAttendanceActions(BuildContext context) {
    return Consumer<FaceDetectionProvider>(
      builder: (context, provider, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (provider.imageOriginal != null) ...[
              FilledButton.icon(
                onPressed: provider.isProcessing
                    ? null
                    : provider.processAndRecordAttendance,
                icon: const Icon(Icons.fact_check),
                label: const Text('Check Attendance'),
              ),
              if (provider.attendanceStats != null) ...[
                const SizedBox(height: 16),
                _buildQuickStats(context, provider),
              ],
            ],
          ],
        );
      },
    );
  }

  Widget _buildRegisteredFacesCount(BuildContext context, int count) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_alt_outlined,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 8),
          Text(
            'Registered Faces: $count',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(
      BuildContext context, FaceDetectionProvider provider) {
    final stats = provider.attendanceStats!;
    return Row(
      children: [
        Expanded(
          child: _buildStatChip(
            context,
            'Present',
            stats.present,
            Colors.green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatChip(
            context,
            'Absent',
            stats.absent,
            Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip(
    BuildContext context,
    String label,
    int value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(color: color),
          ),
          Text(
            value.toString(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
