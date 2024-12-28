import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutterface/ui/home/providers/face_detection_provider.dart';
import 'package:flutterface/ui/shared/buttons/custom_button.dart';

class ImageControls extends StatelessWidget {
  const ImageControls({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FaceDetectionProvider>();

    return Column(
      children: [
        CustomButton(
          icon: provider.isAnalyzed
              ? Icons.person_remove_outlined
              : Icons.people_alt_outlined,
          label: provider.isAnalyzed ? 'Clean result' : 'Detect faces',
          onPressed: provider.isAnalyzed
              ? provider.resetState
              : provider.detectFaces,
        ),
        if (provider.isAnalyzed)
          CustomButton(
            icon: Icons.face_retouching_natural,
            label: 'Align faces',
            onPressed: provider.alignFaces,
          ),
        if (provider.isAligned && !provider.isEmbedded)
          CustomButton(
            icon: Icons.numbers_outlined,
            label: 'Embed face',
            onPressed: provider.embedFace,
          ),
      ],
    );
  }
}

