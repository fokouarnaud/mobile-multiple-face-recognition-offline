import 'dart:typed_data';
import 'package:flutterface/services/face_ml/face_detection/detection.dart';

class ProcessedFace {
  final bool isRegistered;
  final int? registeredId;
  final String? name;
  final Uint8List alignedImage;
  final List<double> embedding;
  final double blurValue;
  final double? similarity;

  ProcessedFace({
    required this.isRegistered,
    this.registeredId,
    this.name,
    required this.alignedImage,
    required this.embedding,
    required this.blurValue,
    this.similarity,
  });
}

class FaceProcessingResult {
  final List<FaceDetectionAbsolute> detections;
  final List<ProcessedFace> processedFaces;

  FaceProcessingResult({
    required this.detections,
    required this.processedFaces,
  });
}