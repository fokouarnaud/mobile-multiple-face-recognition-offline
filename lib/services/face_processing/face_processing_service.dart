import 'dart:convert';
import 'dart:developer' as devtools show log;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutterface/models/face_processing_result.dart';
import 'package:flutterface/models/face_record.dart';
import 'package:flutterface/services/database/face_database_service.dart';
import 'package:flutterface/services/face_ml/face_detection/detection.dart';
import 'package:flutterface/services/face_ml/face_ml_service.dart';

class FaceProcessingService {
  static final FaceProcessingService instance = FaceProcessingService._init();
  final FaceMlService _faceMlService = FaceMlService.instance;
  final FaceDatabaseService _databaseService = FaceDatabaseService.instance;

  FaceProcessingService._init();

  Future<FaceProcessingResult> processImage(
    Uint8List imageData,
    Size imageSize,
    void Function(double progress, String step)? onProgress,
  ) async {
    final results = FaceProcessingResult(
      detections: [],
      alignedFaces: [],
      embeddings: [],
      existingFaces: [],
      blurValues: [],
    );

    try {
      onProgress?.call(0.1, 'Initializing face detection...');

      // 1. Detect faces
      final relativeDetections = await _faceMlService.detectFaces(imageData);

      onProgress?.call(0.3, 'Faces detected');

      final absoluteDetections = relativeToAbsoluteDetections(
        relativeDetections: relativeDetections,
        imageWidth: imageSize.width.round(),
        imageHeight: imageSize.height.round(),
      );
      results.detections.addAll(absoluteDetections);

      // 2. Process each detected face
      for (int i = 0; i < absoluteDetections.length; i++) {
        final face = absoluteDetections[i];
        final progress = 0.3 + (0.6 * (i + 1) / absoluteDetections.length);
        onProgress?.call(
          progress,
          'Processing face ${i + 1} of ${absoluteDetections.length}',
        );

        try {
          // Align face
          final alignedFaces =
              await _faceMlService.alignSingleFaceCustomInterpolation(
            imageData,
            face,
          );
          results.alignedFaces.add(alignedFaces[0]);

          // Get embedding
          final (embedding, _, blurValue) =
              await _faceMlService.embedSingleFace(
            imageData,
            relativeDetections[i],
          );
          results.embeddings.add(embedding);
          results.blurValues.add(blurValue);

          // Check if face exists in database
          final exists = await _databaseService.isFaceExists(embedding);
          results.existingFaces.add(exists);

          // Save new face if it doesn't exist
          if (!exists) {
            final faceRecord = FaceRecord(
              embedding: embedding,
              createdAt: DateTime.now(),
              imageHash: base64Encode(alignedFaces[0]),
            );
            await _databaseService.saveFaceRecord(faceRecord);
          }
        } catch (e) {
          devtools.log('Error processing face $i: $e');
          continue;
        }
      }

      onProgress?.call(0.9, 'Finalizing results...');
      await Future.delayed(const Duration(milliseconds: 200));
      onProgress?.call(1.0, 'Processing complete');

    } catch (e) {
      devtools.log('Error during face processing: $e');
      throw Exception('Face processing failed: $e');
    }

    return results;
  }
}
