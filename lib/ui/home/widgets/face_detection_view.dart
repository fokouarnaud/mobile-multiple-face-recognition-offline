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
      color: Colors.black,
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomButton(
            icon: Icons.image,
            label: 'Gallery',
            onPressed: () async => provider.pickImage(false),
          ),
          CustomButton(
            icon: Icons.photo_camera,
            label: 'Camera',
            onPressed: () async => provider.pickImage(true),
          ),
          CustomButton(
            icon: Icons.collections,
            label: 'Stock',
            onPressed: provider
                .pickStockImage, // You'll need to add this method to provider
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
        child: Text(
          'No image selected',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return provider.isAligned
        ? _buildAlignedFaces(provider)
        : _buildOriginalImage(provider, imageDisplaySize);
  }

  Widget _buildAlignedFaces(FaceDetectionProvider provider) {
    return Center(
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildAlignedFaceColumn(provider.faceAligned!, 'Bilinear'),
            const SizedBox(width: 10),
            _buildAlignedFaceColumn(provider.faceAligned2!, 'Bicubic'),
          ],
        ),
      ),
    );
  }

  Widget _buildAlignedFaceColumn(Image image, String label) {
    return Column(
      children: [
        image,
        Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildOriginalImage(
    FaceDetectionProvider provider,
    Size imageDisplaySize,
  ) {
    return Center(
      child: Stack(
        children: [
          provider.imageOriginal!,
          if (provider.isAnalyzed)
            CustomPaint(
              painter: FacePainter(
                faceDetections: provider.faceDetectionResultsAbsolute,
                imageSize: provider.imageSize,
                availableSize: imageDisplaySize,
              ),
            ),
        ],
      ),
    );
  }
}
