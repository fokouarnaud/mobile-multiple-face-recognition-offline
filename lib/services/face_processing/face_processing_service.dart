// lib/services/face_processing/face_processing_service.dart

import 'dart:developer' as devtools show log;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutterface/models/face_processing_result.dart';
import 'package:flutterface/services/face_ml/face_ml_service.dart';
import 'package:flutterface/services/face_processing/processors/face_alignment_processor.dart';
import 'package:flutterface/services/face_processing/processors/face_detection_processor.dart';
import 'package:flutterface/services/face_processing/processors/face_matching_processor.dart';

class FaceProcessingService {
  static final FaceProcessingService instance = FaceProcessingService._init();

  final FaceMlService _mlService;
  final FaceDetectionProcessor _detectionProcessor;
  final FaceAlignmentProcessor _alignmentProcessor;
  final FaceMatchingProcessor _matchingProcessor;

  FaceProcessingService._init()
      : _mlService = FaceMlService.instance,
        _detectionProcessor = FaceDetectionProcessor(),
        _alignmentProcessor = FaceAlignmentProcessor(),
        _matchingProcessor = FaceMatchingProcessor();

  Future<FaceProcessingResult> processImage(
      Uint8List imageData,
      Size imageSize,
      int boxId, {
        void Function(double progress, String step)? onProgress,
        Future<String?> Function(Uint8List faceImage, List<double> embedding)? onNewFace,
      }) async {
    try {
      // Initialize ML service if needed
      if (!_mlService.initialized) {
        onProgress?.call(0.1, 'Initializing face detection...');
        await _mlService.init();
      }

      // Detect faces (get both coordinate types)
      onProgress?.call(0.3, 'Detecting faces...');
      final detectionResult = await _detectionProcessor.detectFaces(imageData, imageSize);

      final results = FaceProcessingResult(
        detections: detectionResult.absoluteDetections,
        processedFaces: [],
      );

      if (!detectionResult.hasDetections) {
        onProgress?.call(1.0, 'No faces detected');
        return results;
      }

      // Process detected faces
      await _processDetectedFaces(
        results,
        imageData,
        detectionResult,
        boxId,
        onProgress,
        onNewFace,
      );

      onProgress?.call(0.9, 'Finalizing results...');
      await Future.delayed(const Duration(milliseconds: 200));
      onProgress?.call(1.0, 'Processing complete');

      return results;

    } catch (e) {
      devtools.log('Error during face processing: $e');
      throw Exception('Face processing failed: $e');
    }
  }

  Future<void> _processDetectedFaces(
      FaceProcessingResult results,
      Uint8List imageData,
      DetectionResult detectionResult,
      int boxId,
      void Function(double progress, String step)? onProgress,
      Future<String?> Function(Uint8List faceImage, List<double> embedding)? onNewFace,
      ) async {
    for (int i = 0; i < detectionResult.length; i++) {
      final progress = 0.3 + (0.6 * (i + 1) / detectionResult.length);
      onProgress?.call(
        progress,
        'Processing face ${i + 1} of ${detectionResult.length}',
      );

      try {
        // Process face using both coordinate types
        final faceData = await _alignmentProcessor.alignAndGetEmbedding(
          imageData,
          detectionResult.absoluteDetections[i],
          detectionResult.relativeDetections[i],
        );

        // Handle face matching and saving
        final processedFace = await _matchingProcessor.processAndSaveFace(
          faceData,
          boxId,
          onNewFace,
        );

        results.processedFaces.add(processedFace);

      } catch (e) {
        devtools.log('Error processing face $i: $e');
        continue;
      }
    }
  }
}