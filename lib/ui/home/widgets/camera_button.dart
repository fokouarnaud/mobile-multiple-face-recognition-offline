import 'package:flutter/material.dart';
import 'package:flutterface/enums/image_source.dart';
import 'package:flutterface/ui/home/providers/face_detection_provider.dart';
import 'package:provider/provider.dart';

class CameraButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final ImageSource source;
  final bool isMain;

  const CameraButton({
    super.key,
    required this.icon,
    required this.label,
    required this.source,
    this.isMain = false,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FaceDetectionProvider>();
    final theme = Theme.of(context);

    if (isMain) {
      return FloatingActionButton(
        onPressed: provider.isProcessing ? null : () async => _handlePress(provider),
        backgroundColor: theme.colorScheme.primary,
        child: Icon(icon, color: Colors.white),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: provider.isProcessing ? null : () async => _handlePress(provider),
          icon: Icon(icon),
          color: theme.colorScheme.onSurface,
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Future<void> _handlePress(FaceDetectionProvider provider) async {
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