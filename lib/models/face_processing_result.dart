import 'dart:typed_data';
import 'package:flutterface/services/face_ml/face_detection/detection.dart';

class FaceProcessingResult {
  final List<FaceDetectionAbsolute> detections;
  final List<Uint8List> alignedFaces;
  final List<List<double>> embeddings;
  final List<bool> existingFaces;
  final List<double> blurValues;

  FaceProcessingResult({
    required this.detections,
    required this.alignedFaces,
    required this.embeddings,
    required this.existingFaces,
    required this.blurValues,
  });
}