import 'package:flutter/material.dart';
import 'package:flutterface/ui/home/providers/face_detection_provider.dart';
import 'package:flutterface/ui/shared/buttons/custom_button.dart';
import 'package:provider/provider.dart';

class ImageControls extends StatelessWidget {
  const ImageControls({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FaceDetectionProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SizedBox(
        width: double.infinity,
        child: CustomButton(
          icon: provider.isProcessing ? Icons.pending : Icons.people_alt_outlined,
          label: 'Detect faces',
          onPressed: provider.isProcessing ? null : provider.processAndSaveFaces,
          size: ButtonSize.lg,
          style: provider.isProcessing
              ? ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(100),
            foregroundColor: Theme.of(context).colorScheme.onPrimary.withAlpha(150),
          )
              : null,
        ),
      ),
    );
  }
}
