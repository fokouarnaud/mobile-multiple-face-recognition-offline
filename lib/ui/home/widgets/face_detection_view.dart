// lib/ui/home/widgets/face_detection_view.dart

import 'package:flutter/material.dart';
import 'package:flutterface/ui/home/providers/face_detection_provider.dart';
import 'package:flutterface/ui/shared/buttons/custom_button.dart';
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CustomButton(
            icon: Icons.image,
            label: 'Gallery',
            size: ButtonSize.xs,
            onPressed: () async => provider.pickImage(false),
          ),
          CustomButton(
            icon: Icons.photo_camera,
            label: 'Camera',
            size: ButtonSize.xs,
            onPressed: () async => provider.pickImage(true),
          ),
          CustomButton(
            icon: Icons.collections,
            label: 'Stock',
            size: ButtonSize.xs,
            onPressed: provider.pickStockImage,
          ),
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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_search,
              color: Colors.white30,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'No image selected',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
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
        ],
      ),
    );
  }
}