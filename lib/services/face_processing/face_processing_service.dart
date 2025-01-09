import 'dart:developer' as devtools show log;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutterface/models/attendance_record.dart';
import 'package:flutterface/models/attendance_stats.dart';
import 'package:flutterface/models/detection_result.dart';
import 'package:flutterface/models/face_record.dart';
import 'package:flutterface/models/processed_face.dart';
import 'package:flutterface/services/database/face_database_service.dart';
import 'package:flutterface/services/face_ml/face_detection/detection.dart';
import 'package:flutterface/services/face_ml/face_ml_service.dart';

class FaceProcessingService {
  static final FaceProcessingService instance = FaceProcessingService._init();

  final FaceMlService _mlService;
  final FaceDatabaseService _dbService;

  FaceProcessingService._init()
      : _mlService = FaceMlService.instance,
        _dbService = FaceDatabaseService.instance;

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

      return DetectionResult(
        absoluteDetections: absoluteDetections,
        relativeDetections: relativeDetections,
      );
    } catch (e) {
      devtools.log('Error in face detection: $e');
      throw Exception('Face detection failed: $e');
    }
  }

  Future<ProcessedFace> processFace(
      Uint8List imageData,
      FaceDetectionAbsolute detection,
      FaceDetectionRelative relativeDetection,
      ) async {
    try {
      // Get face data
      final faceData = await _mlService.alignSingleFaceCustomInterpolation(
        imageData,
        detection,
      );

      // Get embedding
      final (embedding, _, blurValue) = await _mlService.embedSingleFace(
        imageData,
        relativeDetection,
      );

      // Find matching face
      final matchingFace = await _dbService.faces.findMatchingFace(embedding);

      if (matchingFace != null) {
        return ProcessedFace(
          isRegistered: true,
          registeredId: matchingFace.id,
          name: matchingFace.name,
          alignedImage: faceData[0],
          embedding: embedding,
          blurValue: blurValue,
          similarity: matchingFace.similarity,
        );
      }

      return ProcessedFace(
        isRegistered: false,
        alignedImage: faceData[0],
        embedding: embedding,
        blurValue: blurValue,
      );
    } catch (e) {
      devtools.log('Error processing face: $e');
      throw Exception('Face processing failed: $e');
    }
  }

  Future<void> saveFaceRecord(FaceRecord record) async {
    try {
      await _dbService.faces.saveFaceRecord(record);
    } catch (e) {
      devtools.log('Error saving face record: $e');
      throw Exception('Failed to save face record: $e');
    }
  }



  Future<void> updateFaceRecord(FaceRecord face) async {
    try {
      final result = await _dbService.faces.updateFaceRecord(face);
      if (!result) {
        throw Exception('Failed to update face record');
      }
    } catch (e) {
      devtools.log('Error updating face record: $e');
      throw Exception('Failed to update face record: $e');
    }
  }

  Future<void> deleteFaceRecord(int id) async {
    try {
      await _dbService.faces.deleteFaceRecord(id);
    } catch (e) {
      devtools.log('Error deleting face record: $e');
      throw Exception('Failed to delete face record: $e');
    }
  }

  Future<List<FaceRecord>> getFacesByBoxId(int boxId) async {
    try {
      return await _dbService.faces.getFacesByBoxId(boxId);
    } catch (e) {
      devtools.log('Error getting faces by box ID: $e');
      throw Exception('Failed to get faces: $e');
    }
  }

  Future<void> recordAttendance(
      int faceId,
      int period,
      double similarity,
      String imageHash,
      ) async {
    try {
      await _dbService.attendance.recordAttendance(
        AttendanceRecord(
          id: 0,
          faceId: faceId,
          timestamp: DateTime.now(),
          period: period,
          similarity: similarity,
          detectedImageHash: imageHash,
        ),
      );
    } catch (e) {
      devtools.log('Error recording attendance: $e');
      throw Exception('Failed to record attendance: $e');
    }
  }

  Future<void> recordBatchAttendance(List<AttendanceRecord> records) async {
    try {
      await _dbService.attendance.recordBatchAttendance(records);
    } catch (e) {
      devtools.log('Error recording batch attendance: $e');
      throw Exception('Failed to record batch attendance: $e');
    }
  }

  Future<AttendanceStats> getAttendanceStats(
      int boxId,
      int period,
      DateTime date,
      ) async {
    try {
      return await _dbService.attendance.getAttendanceStats(boxId, period, date);
    } catch (e) {
      devtools.log('Error getting attendance stats: $e');
      throw Exception('Failed to get attendance stats: $e');
    }
  }
}