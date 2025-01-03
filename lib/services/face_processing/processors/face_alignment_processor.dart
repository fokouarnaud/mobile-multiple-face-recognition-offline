// lib/services/face_processing/processors/face_alignment_processor.dart

import 'dart:developer' as devtools show log;
import 'dart:typed_data';

import 'package:flutterface/services/face_ml/face_detection/detection.dart';
import 'package:flutterface/services/face_ml/face_ml_service.dart';

class FaceAlignmentProcessor {
  final FaceMlService _mlService = FaceMlService.instance;

  Future<List<Uint8List>> alignFace(
      Uint8List imageData,
      FaceDetectionAbsolute detection,
      ) async {
    try {
      // Align face with custom interpolation
      final alignedFaces = await _mlService.alignSingleFaceCustomInterpolation(
        imageData,
        detection,
      );

      _validateAlignedFaces(alignedFaces);

      return alignedFaces;

    } catch (e) {
      devtools.log('Error in face alignment: $e');
      throw Exception('Face alignment failed: $e');
    }
  }

  void _validateAlignedFaces(List<Uint8List> alignedFaces) {
    if (alignedFaces.isEmpty || alignedFaces.length != 2) {
      throw Exception('Invalid aligned faces data');
    }

    if (alignedFaces[0].isEmpty || alignedFaces[1].isEmpty) {
      throw Exception('Aligned faces data is empty');
    }
  }

  Future<(Uint8List, List<double>, double)> alignAndGetEmbedding(
      Uint8List imageData,
      FaceDetectionAbsolute detection,
      FaceDetectionRelative relativeDetection,
      ) async {
    try {
      // Get aligned face
      final alignedFaces = await alignFace(imageData, detection);

      // Get embedding
      final (embedding, _, blurValue) = await _mlService.embedSingleFace(
        imageData,
        relativeDetection,
      );

      // Return first aligned face, embedding and blur value
      return (alignedFaces[0], embedding, blurValue);
    } catch (e) {
      devtools.log('Error in alignment and embedding: $e');
      throw Exception('Alignment and embedding failed: $e');
    }
  }
}