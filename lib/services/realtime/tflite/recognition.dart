import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutterface/ui/realtime/camera_view_singleton.dart';

/// Represents the recognition output from the model
class Recognition {
  // Private fields
  /// Index of the result
  final int id;

  /// Label of the result
  final String label;

  /// Confidence [0.0, 1.0]
  final double score;

  /// Location of bounding box rect
  ///
  /// The rectangle corresponds to the raw input image
  /// passed for inference
  final Rect? location; // Optional location

  // Constructor with required parameters
  Recognition({
    required this.id,
    required this.label,
    required this.score,
    this.location,
  });

  /// Returns bounding box rectangle corresponding to the
  /// displayed image on screen
  ///
  /// This is the actual location where rectangle is rendered on
  /// the screen
  Rect get renderLocation {
    // ratioX = screenWidth / imageInputWidth
    // ratioY = ratioX if image fits screenWidth with aspectRatio = constant

    final double ratioX = CameraViewSingleton.ratio;
    final double ratioY = ratioX;

    final double transLeft = max(0.1, location!.left * ratioX);
    final double transTop = max(0.1, location!.top * ratioY);
    final double transWidth = min(
      location!.width * ratioX,
      CameraViewSingleton.actualPreviewSize.width,
    );
    final double transHeight = min(
      location!.height * ratioY,
      CameraViewSingleton.actualPreviewSize.height,
    );

    final Rect transformedRect =
        Rect.fromLTWH(transLeft, transTop, transWidth, transHeight);
    return transformedRect;
  }

  @override
  String toString() {
    return 'Recognition(id: $id, label: $label, score: $score, location: $location)';
  }
}
