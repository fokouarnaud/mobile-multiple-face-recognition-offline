import 'package:flutter/material.dart';
import 'package:flutterface/enums/image_source.dart';
import 'package:flutterface/ui/home/providers/face_detection_provider.dart';
import 'package:provider/provider.dart';

class CameraControls extends StatelessWidget {
  const CameraControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCameraButton(
          context,
          Icons.image,
          'Gallery',
              () async => _handleImageSource(context, ImageSource.gallery),
        ),
        _buildMainCameraButton(
          context,
              () async => _handleImageSource(context, ImageSource.camera),
        ),
        _buildCameraButton(
          context,
          Icons.collections,
          'Stock',
              () async => _handleImageSource(context, ImageSource.stock),
        ),
      ],
    );
  }

  Widget _buildCameraButton(
      BuildContext context,
      IconData icon,
      String label,
      VoidCallback onPressed,
      ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.white),
          iconSize: 28,
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildMainCameraButton(BuildContext context, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: IconButton(
          onPressed: onPressed,
          icon: const Icon(Icons.camera_alt, color: Colors.white),
          iconSize: 32,
        ),
      ),
    );
  }

  Future<void> _handleImageSource(BuildContext context, ImageSource source) async {
    final provider = context.read<FaceDetectionProvider>();
    switch (source) {
      case ImageSource.camera:
        await provider.pickImage(true);
        break;
      case ImageSource.gallery:
        await provider.pickImage(false);
        break;
      case ImageSource.stock:
        await provider.pickStockImage();
        break;
    }
  }
}