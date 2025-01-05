import 'package:flutterface/services/face_ml/face_detection/detection.dart';

class DetectionResult {
  final List<FaceDetectionAbsolute> absoluteDetections;
  final List<FaceDetectionRelative> relativeDetections;

  DetectionResult({
    required this.absoluteDetections,
    required this.relativeDetections,
  });

  bool get hasDetections => absoluteDetections.isNotEmpty;
  int get length => absoluteDetections.length;
}