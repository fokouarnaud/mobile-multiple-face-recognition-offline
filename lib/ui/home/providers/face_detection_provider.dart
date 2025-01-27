// lib/ui/home/providers/face_detection_provider.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterface/models/attendance_record.dart';
import 'package:flutterface/models/attendance_stats.dart';
import 'package:flutterface/models/face_record.dart';
import 'package:flutterface/models/processed_face.dart';
import 'package:flutterface/models/processing_result.dart';
import 'package:flutterface/services/face_processing/face_processing_service.dart';
import 'package:flutterface/services/image/stock_image_service.dart';
import 'package:flutterface/services/snackbar/snackbar_service.dart';
import 'package:flutterface/ui/home/widgets/register_face_dialog.dart';
import 'package:image_picker/image_picker.dart';

class FaceDetectionProvider extends ChangeNotifier {
  // Constructor and Properties
  final int boxId;
  final int period;

  FaceDetectionProvider({
    required this.boxId,
    required this.period,
  }) {
    unawaited(_loadRegisteredFaces());
  }

  // Services
  final FaceProcessingService _faceProcService = FaceProcessingService.instance;
  final _snackbar = SnackbarService.instance;
  final ImagePicker _picker = ImagePicker();
  final StockImageService _stockImageService = StockImageService.instance;

  // Processing State
  bool _isProcessing = false;
  double _processingProgress = 0.0;
  String _processingStep = '';
  ProcessingResult? _processingResult;

  // UI State
  Image? _imageOriginal;
  Uint8List? _imageData;
  Size _imageSize = Size.zero;
  List<FaceRecord> _registeredFaces = [];
  AttendanceStats? _attendanceStats;
  int _stockImageIndex = 0;

  // Getters
  bool get isProcessing => _isProcessing;
  double get processingProgress => _processingProgress;
  String get processingStep => _processingStep;
  ProcessingResult? get processingResult => _processingResult;
  Image? get imageOriginal => _imageOriginal;
  Size get imageSize => _imageSize;
  List<FaceRecord> get registeredFaces => _registeredFaces;
  int get registeredFacesCount => _registeredFaces.length;
  AttendanceStats? get attendanceStats => _attendanceStats;
  bool get hasImage => _imageData != null;

  // Image Selection Methods
  Future<void> pickImage(bool fromCamera) async {
    try {
      final XFile? image = fromCamera
          ? await _picker.pickImage(source: ImageSource.camera)
          : await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        await _loadImage(image);
      }
    } catch (e) {
      _snackbar.showError('Failed to pick image: $e');
    }
  }

  Future<void> pickStockImage() async {
    try {
      final (imageData, path) =
          await _stockImageService.getNextStockImage(_stockImageIndex);
      _imageData = imageData;

      final decodedImage = await decodeImageFromList(_imageData!);
      _imageOriginal = Image.asset(path);
      _imageSize = Size(
        decodedImage.width.toDouble(),
        decodedImage.height.toDouble(),
      );

      _stockImageIndex =
          (_stockImageIndex + 1) % _stockImageService.stockImagePaths.length;

      _resetProcessingState();
      notifyListeners();
    } catch (e) {
      _snackbar.showError('Failed to load stock image: $e');
    }
  }

  Future<void> _loadImage(XFile image) async {
    _resetProcessingState();

    try {
      _imageData = await image.readAsBytes();
      final decodedImage = await decodeImageFromList(_imageData!);

      _imageOriginal = Image.file(File(image.path));
      _imageSize = Size(
        decodedImage.width.toDouble(),
        decodedImage.height.toDouble(),
      );

      notifyListeners();
    } catch (e) {
      _snackbar.showError('Failed to load image: $e');
    }
  }

  // Face Registration
  Future<void> detectAndRegisterFaces(BuildContext context) async {
    if (!hasImage) {
      _snackbar.showError('Please select an image first');
      return;
    }

    _updateProcessingState(true, step: 'Detecting faces...', progress: 0.1);

    try {
      final detectionResult =
          await _faceProcService.detectFaces(_imageData!, _imageSize);
      _updateProcessingState(true, step: 'Processing faces...', progress: 0.3);

      final processedFaces = <ProcessedFace>[];
      for (var i = 0; i < detectionResult.absoluteDetections.length; i++) {
        final progress =
            0.3 + (0.6 * (i + 1) / detectionResult.absoluteDetections.length);
        _updateProcessingState(
          true,
          step:
              'Processing face ${i + 1} of ${detectionResult.absoluteDetections.length}',
          progress: progress,
        );

        final face = await _faceProcService.processFace(
          _imageData!,
          detectionResult.absoluteDetections[i],
          detectionResult.relativeDetections[i],
        );
        processedFaces.add(face);
      }

      _processingResult = ProcessingResult(
        detections: detectionResult,
        processedFaces: processedFaces,
      );

      _updateProcessingState(true, step: 'Done', progress: 1.0);
      notifyListeners();

      if (context.mounted) {
        await _processDetectedFaces(context);
      }

      await _loadRegisteredFaces();
    } catch (e) {
      _snackbar.showError('Face detection failed: $e');
    } finally {
      _updateProcessingState(false);
    }
  }

  Future<void> _processDetectedFaces(BuildContext context) async {
    if (_processingResult == null) return;

    for (final face in _processingResult!.processedFaces) {
      if (!face.isRegistered && context.mounted) {
        final name = await _showRegisterDialog(context, face);
        if (name != null) {
          await saveFaceRecord(face, name);
        }
      }
    }
  }

  Future<String?> _showRegisterDialog(
    BuildContext context,
    ProcessedFace face,
  ) async {
    if (!context.mounted) return null;

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => RegisterFaceDialog(
        faceImage: face.alignedImage,
        embedding: face.embedding,
      ),
    );
  }
  // Add these methods to FaceDetectionProvider class

  Future<void> updateFaceRecord(FaceRecord face) async {
    try {
      await _faceProcService.updateFaceRecord(face);
      _snackbar.showSuccess('Face updated successfully');
      await _loadRegisteredFaces();
    } catch (e) {
      _snackbar.showError('Failed to update face: $e');
    }
  }

  Future<void> deleteFaceRecord(int id) async {
    try {
      await _faceProcService.deleteFaceRecord(id);
      _snackbar.showSuccess('Face deleted successfully');
      await _loadRegisteredFaces();
    } catch (e) {
      _snackbar.showError('Failed to delete face: $e');
    }
  }

  Future<void> saveFaceRecord(ProcessedFace face, String name) async {
    try {
      final record = FaceRecord(
        name: name,
        boxId: boxId,
        embedding: face.embedding,
        createdAt: DateTime.now(),
        imageHash: base64Encode(face.alignedImage),
      );

      await _faceProcService.saveFaceRecord(record);
      _snackbar.showSuccess('Face registered successfully');
      await _loadRegisteredFaces();
    } catch (e) {
      _snackbar.showError('Failed to save face: $e');
    }
  }

  // Attendance Processing
  Future<void> processAndRecordAttendance() async {
    if (!hasImage) {
      _snackbar.showError('Please select an image first');
      return;
    }

    _updateProcessingState(
      true,
      step: 'Processing attendance...',
      progress: 0.0,
    );

    try {
      final detectionResult =
          await _faceProcService.detectFaces(_imageData!, _imageSize);
      _updateProcessingState(true, step: 'Processing faces...', progress: 0.3);

      final processedFaces = <ProcessedFace>[];
      for (var i = 0; i < detectionResult.absoluteDetections.length; i++) {
        final progress =
            0.3 + (0.6 * (i + 1) / detectionResult.absoluteDetections.length);
        _updateProcessingState(
          true,
          step:
              'Processing face ${i + 1} of ${detectionResult.absoluteDetections.length}',
          progress: progress,
        );

        final face = await _faceProcService.processFace(
          _imageData!,
          detectionResult.absoluteDetections[i],
          detectionResult.relativeDetections[i],
        );
        processedFaces.add(face);
      }

      _processingResult = ProcessingResult(
        detections: detectionResult,
        processedFaces: processedFaces,
      );

      // Record attendance for registered faces
      _updateProcessingState(
        true,
        step: 'Recording attendance...',
        progress: 0.9,
      );

      final attendanceRecords = _processingResult!.processedFaces
          .where((face) => face.isRegistered && face.registeredId != null)
          .map(
            (face) => AttendanceRecord(
              id: 0,
              faceId: face.registeredId!,
              timestamp: DateTime.now(),
              period: period,
              similarity: face.similarity ?? 0,
              detectedImageHash: base64Encode(face.alignedImage),
            ),
          )
          .toList();

      await _faceProcService.recordBatchAttendance(attendanceRecords);

      // Update stats
      _attendanceStats = await _faceProcService.getAttendanceStats(
        boxId,
        period,
        DateTime.now(),
      );

      _updateProcessingState(true, step: 'Done', progress: 1.0);
      _snackbar.showSuccess('Attendance recorded successfully');
      notifyListeners();
    } catch (e) {
      _snackbar.showError('Failed to record attendance: $e');
    } finally {
      _updateProcessingState(false);
    }
  }

  // Helper Methods
  Future<void> _loadRegisteredFaces() async {
    try {
      _registeredFaces = await _faceProcService.getFacesByBoxId(boxId);
      notifyListeners();
    } catch (e) {
      _snackbar.showError('Failed to load registered faces: $e');
    }
  }

  void _updateProcessingState(
    bool isProcessing, {
    String step = '',
    double progress = 0.0,
  }) {
    _isProcessing = isProcessing;
    _processingStep = step;
    _processingProgress = progress;
    notifyListeners();
  }

  void _resetProcessingState() {
    _isProcessing = false;
    _processingProgress = 0.0;
    _processingStep = '';
    _processingResult = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _resetProcessingState();
    _registeredFaces.clear();
    super.dispose();
  }
}
