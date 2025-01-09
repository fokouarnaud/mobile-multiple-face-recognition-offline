import 'package:flutter/material.dart';
import 'package:flutterface/ui/home/providers/face_detection_provider.dart';
import 'package:provider/provider.dart';

class ProcessingOverlay extends StatelessWidget {
  const ProcessingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FaceDetectionProvider>();

    return Scaffold(
      backgroundColor: Colors.black.withAlpha(178), // Semi-transparent background
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400), // Limit width for better readability
          margin: const EdgeInsets.all(20), // Add margin for better spacing
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
                  // Circular progress indicator with a label
                  const CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), // Custom color
                  ),
                  const SizedBox(height: 20),
                  Text(
                    provider.processingStep,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Linear progress indicator with a label
                  LinearProgressIndicator(
                    value: provider.processingProgress,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue), // Custom color
                    minHeight: 8, // Thicker progress bar
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(provider.processingProgress * 100).toStringAsFixed(0)}%', // Show progress percentage
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}