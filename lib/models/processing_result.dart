// lib/models/processing_result.dart

import 'package:flutterface/models/detection_result.dart';
import 'package:flutterface/models/processed_face.dart';

class ProcessingResult {
  final DetectionResult detections;
  final List<ProcessedFace> processedFaces;

  ProcessingResult({
    required this.detections,
    required this.processedFaces,
  });
}