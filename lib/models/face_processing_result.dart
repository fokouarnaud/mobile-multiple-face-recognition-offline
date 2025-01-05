// lib/services/face_processing/models/processed_face_result.dart

import 'package:flutterface/models/processed_face.dart';
import 'package:flutterface/services/face_ml/face_detection/detection.dart';



class FaceProcessingResult {
  final List<FaceDetectionAbsolute> detections;
  final List<ProcessedFace> processedFaces;

  FaceProcessingResult({
    required this.detections,
    required this.processedFaces,
  });

  bool get hasDetections => detections.isNotEmpty;
  int get totalFaces => detections.length;
  int get registeredFaces => processedFaces.where((face) => face.isRegistered).length;
  int get newFaces => processedFaces.where((face) => !face.isRegistered).length;

  List<ProcessedFace> get registeredProcessedFaces =>
      processedFaces.where((face) => face.isRegistered).toList();

  List<ProcessedFace> get newProcessedFaces =>
      processedFaces.where((face) => !face.isRegistered).toList();
}