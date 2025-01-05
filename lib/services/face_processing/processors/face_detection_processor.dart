
import 'dart:developer' as devtools show log;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutterface/models/detection_result.dart';
import 'package:flutterface/services/face_ml/face_detection/detection.dart';
import 'package:flutterface/services/face_ml/face_ml_service.dart';



class FaceDetectionProcessor {
  final FaceMlService _mlService = FaceMlService.instance;

  Future<DetectionResult> detectFaces(
      Uint8List imageData,
      Size imageSize,
      ) async {
    try {
      // Get relative coordinates from ML
      final relativeDetections = await _mlService.detectFaces(imageData);
      devtools.log('Detected ${relativeDetections.length} faces');

      // Convert to absolute coordinates
      final absoluteDetections = relativeToAbsoluteDetections(
        relativeDetections: relativeDetections,
        imageWidth: imageSize.width.round(),
        imageHeight: imageSize.height.round(),
      );

      _validateDetections(absoluteDetections);

      // Return both coordinate types
      return DetectionResult(
        absoluteDetections: absoluteDetections,
        relativeDetections: relativeDetections,
      );

    } catch (e) {
      devtools.log('Error in face detection: $e');
      throw Exception('Face detection failed: $e');
    }
  }

  void _validateDetections(List<FaceDetectionAbsolute> detections) {
    if (detections.isEmpty) {
      devtools.log('No faces detected in image');
      return;
    }

    for (int i = 0; i < detections.length; i++) {
      final detection = detections[i];
      if (!_isValidDetection(detection)) {
        devtools.log('Invalid face detection at index $i: $detection');
      }
    }
  }

  bool _isValidDetection(FaceDetectionAbsolute detection) {
    return detection.xMinBox >= 0 &&
        detection.yMinBox >= 0 &&
        detection.width > 0 &&
        detection.height > 0;
  }
}