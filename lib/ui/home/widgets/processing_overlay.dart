import 'package:flutter/material.dart';
import 'package:flutterface/ui/home/providers/face_detection_provider.dart';
import 'package:provider/provider.dart';

class ProcessingOverlay extends StatelessWidget {
  const ProcessingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FaceDetectionProvider>();

    return Container(
      color: Colors.black.withAlpha(178),
      child: Center(
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  provider.processingStep,
                  style: Theme.of(context).textTheme.titleSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: provider.processingProgress,
                  backgroundColor: Colors.grey[200],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
