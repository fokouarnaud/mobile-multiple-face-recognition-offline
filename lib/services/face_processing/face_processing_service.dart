import 'dart:convert';
import 'dart:developer' as devtools show log;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutterface/models/attendance_record.dart';
import 'package:flutterface/models/detection_result.dart';
import 'package:flutterface/models/face_processing_result.dart';
import 'package:flutterface/models/processed_face.dart';
import 'package:flutterface/services/database/repositories/attendance_repository.dart';
import 'package:flutterface/services/database/repositories/face_repository.dart';
import 'package:flutterface/services/face_ml/face_detection/detection.dart';
import 'package:flutterface/services/face_ml/face_ml_service.dart';
import 'package:flutterface/services/face_processing/processors/face_alignment_processor.dart';

class FaceProcessingService {
  static final FaceProcessingService instance = FaceProcessingService._init();

  final FaceMlService _mlService;
  final FaceRepository _faceRepo;
  final AttendanceRepository _attendanceRepo;
  final FaceAlignmentProcessor _alignmentProcessor;

  FaceProcessingService._init()
      : _mlService = FaceMlService.instance,
        _faceRepo = FaceRepository(),
        _attendanceRepo = AttendanceRepository(),
        _alignmentProcessor = FaceAlignmentProcessor();

  Future<DetectionResult> _detectFaces(
    Uint8List imageData,
    Size imageSize,
  ) async {
    try {
      final relativeDetections = await _mlService.detectFaces(imageData);
      devtools.log('Detected ${relativeDetections.length} faces');

      final absoluteDetections = relativeToAbsoluteDetections(
        relativeDetections: relativeDetections,
        imageWidth: imageSize.width.round(),
        imageHeight: imageSize.height.round(),
      );

      return DetectionResult(
        absoluteDetections: absoluteDetections,
        relativeDetections: relativeDetections,
      );
    } catch (e) {
      devtools.log('Error in face detection: $e');
      throw Exception('Face detection failed: $e');
    }
  }

  Future<List<AttendanceRecord>> _processDetectedFaces(
    FaceProcessingResult results,
    Uint8List imageData,
    DetectionResult detectionResult,
    int boxId,
    int period,
    void Function(double progress, String step)? onProgress,
  ) async {
    final attendanceRecords = <AttendanceRecord>[];
    final now = DateTime.now();

    for (int i = 0; i < detectionResult.length; i++) {
      final progress = 0.3 + (0.6 * (i + 1) / detectionResult.length);
      onProgress?.call(
        progress,
        'Processing face ${i + 1} of ${detectionResult.length}',
      );

      try {
        // Process face using both coordinate types
        final (alignedImage, embedding, blurValue) =
            await _alignmentProcessor.alignAndGetEmbedding(
          imageData,
          detectionResult.absoluteDetections[i],
          detectionResult.relativeDetections[i],
        );

        // Try to find matching face
        final matchingFace = await _faceRepo.findMatchingFace(embedding);

        if (matchingFace != null) {
          // Check if attendance already recorded for this period
          final hasAttendance = await _attendanceRepo.hasAttendanceForPeriod(
            matchingFace.id,
            period,
            now,
          );

          if (!hasAttendance) {
            // Record new attendance
            attendanceRecords.add(
              AttendanceRecord(
                id: 0,
                faceId: matchingFace.id,
                timestamp: now,
                period: period,
                similarity: matchingFace.similarity,
                detectedImageHash: base64Encode(alignedImage),
              ),
            );
          }

          // Convert matching face to processed face
          results.processedFaces.add(
            ProcessedFace(
              isRegistered: true,
              registeredId: matchingFace.id,
              name: matchingFace.name,
              alignedImage: alignedImage,
              embedding: embedding,
              blurValue: blurValue,
              similarity: matchingFace.similarity,
            ),
          );
        }
      } catch (e) {
        devtools.log('Error processing face $i: $e');
        continue;
      }
    }

    return attendanceRecords;
  }

  Future<FaceProcessingResult> processImage(
    Uint8List imageData,
    Size imageSize,
    int boxId,
    int period,
    void Function(double progress, String step)? onProgress,
  ) async {
    try {
      if (!_mlService.initialized) {
        onProgress?.call(0.1, 'Initializing face detection...');
        await _mlService.init();
      }

      onProgress?.call(0.3, 'Detecting faces...');
      final detectionResult = await _detectFaces(imageData, imageSize);

      final results = FaceProcessingResult(
        detections: detectionResult.absoluteDetections,
        processedFaces: [],
      );

      if (!detectionResult.hasDetections) {
        onProgress?.call(1.0, 'No faces detected');
        return results;
      }

      final attendanceRecords = await _processDetectedFaces(
        results,
        imageData,
        detectionResult,
        boxId,
        period,
        onProgress,
      );

      if (attendanceRecords.isNotEmpty) {
        await _attendanceRepo.recordBatchAttendance(attendanceRecords);
      }

      onProgress?.call(0.9, 'Finalizing results...');
      await Future.delayed(const Duration(milliseconds: 200));
      onProgress?.call(1.0, 'Processing complete');

      return results;
    } catch (e) {
      devtools.log('Error during face processing: $e');
      throw Exception('Face processing failed: $e');
    }
  }
}
