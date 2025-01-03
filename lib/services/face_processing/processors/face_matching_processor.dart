import 'dart:convert';
import 'dart:developer' as devtools show log;
import 'dart:typed_data';

import 'package:flutterface/models/face_processing_result.dart';
import 'package:flutterface/models/face_record.dart';
import 'package:flutterface/services/database/face_database_service.dart';
import 'package:flutterface/services/database/models/face_match.dart';

class FaceMatchingProcessor {
  final FaceDatabaseService _dbService = FaceDatabaseService.instance;

  Future<ProcessedFace> processAndSaveFace(
      (Uint8List, List<double>, double) faceData,
      int boxId,
      Future<String?> Function(Uint8List faceImage, List<double> embedding)? onNewFace,
      ) async {
    try {
      final (alignedImage, embedding, blurValue) = faceData;

      // Find matching face in database
      final matchingFace = await _dbService.faces.findMatchingFace(embedding);

      if (matchingFace == null) {
        // Handle new face
        final name = await onNewFace?.call(alignedImage, embedding);
        if (name != null) {
          final faceRecord = FaceRecord(
            name: name,
            boxId: boxId,
            embedding: embedding,
            createdAt: DateTime.now(),
            imageHash: base64Encode(alignedImage),
          );
          await _dbService.faces.saveFaceRecord(faceRecord);
        }

        return ProcessedFace(
          isRegistered: false,
          alignedImage: alignedImage,
          embedding: embedding,
          blurValue: blurValue,
          name: name,
        );
      } else {
        // Handle existing face
        return ProcessedFace(
          isRegistered: true,
          registeredId: matchingFace.id,
          name: matchingFace.name,
          alignedImage: alignedImage,
          embedding: embedding,
          blurValue: blurValue,
          similarity: matchingFace.similarity,
        );
      }
    } catch (e) {
      devtools.log('Error processing face: $e');
      throw Exception('Face processing failed: $e');
    }
  }

  Future<ProcessedFace> processExistingFace(
      (Uint8List, List<double>, double) faceData,
      FaceMatch matchingFace,
      ) async {
    final (alignedImage, embedding, blurValue) = faceData;

    return ProcessedFace(
      isRegistered: true,
      registeredId: matchingFace.id,
      name: matchingFace.name,
      alignedImage: alignedImage,
      embedding: embedding,
      blurValue: blurValue,
      similarity: matchingFace.similarity,
    );
  }
}