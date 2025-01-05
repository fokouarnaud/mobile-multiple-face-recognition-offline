import 'package:flutter/material.dart';
import 'package:flutterface/ui/home/providers/face_detection_provider.dart';
import 'package:flutterface/ui/home/widgets/camera_controls.dart';
import 'package:flutterface/ui/home/widgets/empty_state_view.dart';
import 'package:flutterface/ui/home/widgets/processing_overlay.dart';
import 'package:flutterface/utils/face_detection_painter.dart';
import 'package:provider/provider.dart';

class FaceDetectionView extends StatelessWidget {
  const FaceDetectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FaceDetectionProvider>();
    final imageDisplaySize = Size(
      MediaQuery.of(context).size.width * 0.8,
      MediaQuery.of(context).size.width * 0.8 * 1.5,
    );

    return Container(
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
          _buildImageButtons(context, provider),
        ],
      ),
    );

  }

  Widget _buildImageButtons(
      BuildContext context,
      FaceDetectionProvider provider,
      ) {
    return Container(
      padding: const EdgeInsets.all(8.0),
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
      child: const CameraControls(),
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

    return _buildOriginalImage(provider, imageDisplaySize);
  }

  Widget _buildOriginalImage(
      FaceDetectionProvider provider,
      Size imageDisplaySize,
      ) {
    return Center(
      child: Stack(
        children: [
          provider.imageOriginal!,
          if (provider.processingResult?.detections != null)
            CustomPaint(
              painter: FacePainter(
                faceDetections: provider.processingResult!.detections,
                imageSize: provider.imageSize,
                availableSize: imageDisplaySize,
              ),
            ),
          if (provider.isProcessing)
            const ProcessingOverlay(),
        ],
      ),
    );
  }
}

