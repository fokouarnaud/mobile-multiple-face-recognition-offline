// lib/ui/home/widgets/face_detection_view.dart

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutterface/models/face_record.dart';
import 'package:flutterface/ui/home/providers/face_detection_provider.dart';
import 'package:flutterface/ui/home/widgets/camera_controls.dart';
import 'package:flutterface/ui/home/widgets/edit_face_dialog.dart';
import 'package:flutterface/ui/home/widgets/empty_state_view.dart';
import 'package:flutterface/ui/home/widgets/processing_overlay.dart';
import 'package:flutterface/utils/date_formatter.dart';
import 'package:flutterface/utils/face_detection_painter.dart';
import 'package:provider/provider.dart';

class FaceDetectionView extends StatelessWidget {
  final bool isRegistrationMode;

  const FaceDetectionView({
    super.key,
    required this.isRegistrationMode,
  });

  @override
  Widget build(BuildContext context) {
    final imageDisplaySize = Size(
      MediaQuery.of(context).size.width * 0.8,
      MediaQuery.of(context).size.width * 0.8 * 1.5,
    );

    return Consumer<FaceDetectionProvider>(
      builder: (context, provider, _) {
        return CustomScrollView(
          slivers: [
            // Fixed Video-like Frame at Top
            SliverToBoxAdapter(
              child: Center(
                child: Container(
                  height: imageDisplaySize.height,
                  width: imageDisplaySize.width,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      _buildImageContent(context, provider, imageDisplaySize),
                      if (provider.imageOriginal != null) _buildOverlays(),
                      _buildControls(),
                    ],
                  ),
                ),
              ),
            ),

            // Rest of the content...
            const SliverToBoxAdapter(
              child: SizedBox(height: 8),
            ),
            SliverToBoxAdapter(
              child: _buildStatistics(context, provider),
            ),
            SliverToBoxAdapter(
              child: _buildActionButtons(context, provider),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: isRegistrationMode
                  ? _buildRegistrationList(provider)
                  : _buildAttendanceList(provider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatistics(
    BuildContext context,
    FaceDetectionProvider provider,
  ) {
    final theme = Theme.of(context);

    if (isRegistrationMode) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Registration Statistics',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      context,
                      'Total Registered',
                      provider.registeredFacesCount.toString(),
                      Icons.people,
                    ),
                    if (provider.processingResult != null)
                      _buildStatItem(
                        context,
                        'Detected',
                        provider.processingResult!.detections.length.toString(),
                        Icons.face,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // Attendance Statistics
      if (provider.attendanceStats == null) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Attendance Statistics',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      context,
                      'Present',
                      provider.attendanceStats!.present.toString(),
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    _buildStatItem(
                      context,
                      'Absent',
                      provider.attendanceStats!.absent.toString(),
                      Icons.cancel,
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    final theme = Theme.of(context);
    final displayColor = color ?? theme.colorScheme.primary;

    return Column(
      children: [
        Icon(icon, color: displayColor, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: displayColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    FaceDetectionProvider provider,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          isRegistrationMode
              ? FilledButton.icon(
                  onPressed: provider.imageOriginal == null ||
                          provider.isProcessing
                      ? null
                      : () async => provider.detectAndRegisterFaces(context),
                  icon: const Icon(Icons.face),
                  label: const Text('Register Faces'),
                )
              : FilledButton.icon(
                  onPressed:
                      provider.imageOriginal == null || provider.isProcessing
                          ? null
                          : provider.processAndRecordAttendance,
                  icon: const Icon(Icons.fact_check),
                  label: const Text('Check Attendance'),
                ),
          if (!isRegistrationMode && provider.processingResult != null) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: provider.exportAttendanceReport,
              icon: const Icon(Icons.download),
              label: const Text('Export to Excel'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImageContent(
    BuildContext context,
    FaceDetectionProvider provider,
    Size imageDisplaySize,
  ) {
    if (provider.imageOriginal == null) {
      return const EmptyStateView();
    }

    return Center(
      child: Stack(
        children: [
          provider.imageOriginal!,
          if (provider.processingResult != null)
            CustomPaint(
              painter: FacePainter(
                faceDetections:
                    provider.processingResult!.detections.absoluteDetections,
                imageSize: provider.imageSize,
                availableSize: imageDisplaySize,
              ),
            ),
          if (provider.isProcessing) const ProcessingOverlay(),
        ],
      ),
    );
  }

  Widget _buildOverlays() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withAlpha(178),
            Colors.transparent,
          ],
          stops: const [0.0, 0.8],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return const Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: CameraControls(),
      ),
    );
  }

  Widget _buildRegistrationList(FaceDetectionProvider provider) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final face = provider.registeredFaces[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: MemoryImage(face.alignedImage),
              ),
              title: Text(face.name),
              subtitle: Text(
                'Registered on ${DateFormatter.formatDate(face.createdAt)}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async => _showEditDialog(context, face),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async =>
                        _showDeleteConfirmation(context, face),
                  ),
                ],
              ),
            ),
          );
        },
        childCount: provider.registeredFaces.length,
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, FaceRecord face) async {
    context.read<FaceDetectionProvider>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => EditFaceDialog(face: face),
    );

    if (result == true) {
      // Handle the result if needed
    }
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    FaceRecord face,
  ) async {
    final provider = context.read<FaceDetectionProvider>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Face'),
        content: Text('Are you sure you want to delete "${face.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true && face.id != null) {
      await provider.deleteFaceRecord(face.id!);
    }
  }

  Widget _buildAttendanceList(FaceDetectionProvider provider) {
    if (provider.processingResult == null) return const SliverToBoxAdapter();

    // Filter processed faces to only show those matching faces from current box
    final present = provider.processingResult!.processedFaces
        .where(
          (face) =>
              face.isRegistered &&
              provider.registeredFaces
                  .any((registered) => registered.id == face.registeredId),
        )
        .toList();

    // Get absent faces from current box's registered faces
    final absent = provider.registeredFaces
        .where(
          (registered) => !present
              .any((detected) => detected.registeredId == registered.id),
        )
        .toList();

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == 0) {
            return _buildListHeader(context, 'Present', present.length);
          }
          if (index == present.length + 1) {
            return _buildListHeader(context, 'Absent', absent.length);
          }

          if (index <= present.length) {
            final face = present[index - 1];
            return _buildAttendanceItem(
              face.alignedImage,
              face.name ?? 'Unknown',
              face.similarity ?? 0,
              true,
            );
          } else {
            final face = absent[index - present.length - 2];
            return _buildAttendanceItem(
              face.alignedImage,
              face.name,
              0,
              false,
            );
          }
        },
        childCount: present.length + absent.length + 2, // +2 for headers
      ),
    );
  }

  Widget _buildListHeader(BuildContext context, String title, int count) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Row(
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceItem(
    Uint8List image,
    String name,
    double similarity,
    bool isPresent,
  ) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: MemoryImage(image),
        ),
        title: Text(name),
        trailing: isPresent
            ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${(similarity * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            : const Icon(
                Icons.cancel,
                color: Colors.red,
              ),
      ),
    );
  }
}
