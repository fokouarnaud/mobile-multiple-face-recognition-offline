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
          buildImageContent(context, provider, imageDisplaySize),
          buildImageButtons(context, provider),
        ],
      ),
    );
  }

  Widget buildImageButtons(
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

  Widget buildImageContent(
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

    return buildOriginalImage(provider, imageDisplaySize);
  }

  Widget buildOriginalImage(
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
                faceDetections: provider.processingResult?.detections ?? [],
                imageSize: provider.imageSize,
                availableSize: imageDisplaySize,
              ),
            ),
        ],
      ),
    );
  }
}