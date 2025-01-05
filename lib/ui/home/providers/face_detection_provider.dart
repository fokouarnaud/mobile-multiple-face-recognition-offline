//lib/providers/face_detection_provider.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterface/models/attendance_stats.dart';
import 'package:flutterface/models/face_processing_result.dart';
import 'package:flutterface/models/face_record.dart';
import 'package:flutterface/models/processed_face.dart';
import 'package:flutterface/services/database/repositories/attendance_repository.dart';
import 'package:flutterface/services/database/repositories/face_repository.dart';
import 'package:flutterface/services/face_processing/face_processing_service.dart';
import 'package:flutterface/services/image/stock_image_service.dart';
import 'package:flutterface/services/snackbar/snackbar_service.dart';

import 'package:flutterface/ui/home/widgets/register_face_dialog.dart';
import 'package:image_picker/image_picker.dart';

class FaceDetectionProvider extends ChangeNotifier {
  final int boxId;
  int _period;

  FaceDetectionProvider({
    required this.boxId,
    required int period,
  }) : _period = period;

  // Getter for current period
  int get period => _period;

  // Services
  final ImagePicker _picker = ImagePicker();
  final FaceProcessingService _faceProcessingService = FaceProcessingService.instance;
  final FaceRepository _faceRepo = FaceRepository();
  final AttendanceRepository _attendanceRepo = AttendanceRepository();
  final StockImageService _stockImageService = StockImageService.instance;
  final _snackbarService = SnackbarService.instance;

  // Image State
  Image? imageOriginal;
  Uint8List? imageOriginalData;
  Size imageSize = const Size(0, 0);
  int stockImageCounter = 0;

  // Processing State
  FaceProcessingResult? processingResult;
  bool isProcessing = false;
  double processingProgress = 0.0;
  String processingStep = '';

  // Attendance Stats
  AttendanceStats? attendanceStats;

  // Face Records
  List<FaceRecord> _registeredFaces = [];
  List<ProcessedFace> _processedFaces = [];

  // Getters
  int get registeredFacesCount => _registeredFaces.length;
  List<FaceRecord> get registeredFaces => _registeredFaces;

  List<ProcessedFace> get presentFaces => _processedFaces
      .where((face) => face.isRegistered && (face.similarity ?? 0) >= 0.6)
      .toList();

  List<ProcessedFace> get absentFaces {
    final presentIds = presentFaces.map((f) => f.registeredId).toSet();
    return _registeredFaces
        .where((face) => !presentIds.contains(face.id))
        .map((face) => ProcessedFace(
      isRegistered: true,
      registeredId: face.id,
      name: face.name,
      alignedImage: _decodeImageHash(face.imageHash),
      embedding: face.embedding,
      blurValue: 0,
    ),)
        .toList();
  }

  // Image Selection Methods
  Future<void> pickImage(bool fromCamera) async {
    _resetProcessingState();
    final XFile? image = fromCamera
        ? await _picker.pickImage(source: ImageSource.camera)
        : await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      await _processImage(image);
    }
  }

  Future<void> pickStockImage() async {
    try {
      _resetProcessingState();
      final (imageData, path) = await _stockImageService.getNextStockImage(stockImageCounter);
      imageOriginalData = imageData;

      final decodedImage = await decodeImageFromList(imageOriginalData!);
      imageOriginal = Image.asset(path);
      imageSize = Size(
        decodedImage.width.toDouble(),
        decodedImage.height.toDouble(),
      );

      stockImageCounter = (stockImageCounter + 1) % _stockImageService.stockImagePaths.length;
      notifyListeners();
    } catch (e) {
      _snackbarService.showError('Failed to load stock image: $e');
    }
  }

  Future<void> _processImage(XFile image) async {
    try {
      imageOriginalData = await image.readAsBytes();
      final decodedImage = await decodeImageFromList(imageOriginalData!);
      imageOriginal = Image.file(File(image.path));
      imageSize = Size(
        decodedImage.width.toDouble(),
        decodedImage.height.toDouble(),
      );
      notifyListeners();
    } catch (e) {
      _snackbarService.showError('Failed to process image: $e');
    }
  }


  // Attendance Processing
  Future<void> processAndRecordAttendance() async {
    if (imageOriginalData == null) {
      _snackbarService.showError('Please select an image first');
      return;
    }

    _setProcessingState(true);

    try {
      processingResult = await _faceProcessingService.processImage(
        imageOriginalData!,
        imageSize,
        boxId,
        _period,  // Use current period
        _updateProgress,
      );

      _processedFaces = processingResult!.processedFaces;
      await _updateAttendanceStats();
      _showAttendanceResults();

    } catch (e) {
      _snackbarService.showError('Attendance processing failed: $e');
    } finally {
      _setProcessingState(false);
    }
  }

  // Update period method
  void updatePeriod(int newPeriod) {
    _period = newPeriod;
    // Reset state when period changes
    _resetProcessingState();
    // Optionally update stats for new period
    if (processingResult != null) {
      _updateAttendanceStats();
    }
  }
  // Helper Methods
  Future<void> _loadRegisteredFaces() async {
    _registeredFaces = await _faceRepo.getFacesByBoxId(boxId);
    notifyListeners();
  }



  Future<void> _updateAttendanceStats() async {
    attendanceStats = await _attendanceRepo.getAttendanceStats(
      boxId,
      _period,  // Use current period
      DateTime.now(),
    );
    notifyListeners();
  }

  void _showAttendanceResults() {
    if (processingResult == null || !processingResult!.hasDetections) {
      _snackbarService.showError('No faces detected');
      return;
    }

    if (attendanceStats != null) {
      _snackbarService.showSuccess(
        'Found ${processingResult!.detections.length} faces\n'
            'Present: ${attendanceStats!.present}\n'
            'Absent: ${attendanceStats!.absent}\n'
            'Total Registered: ${attendanceStats!.totalRegistered}',
      );
    }
  }



  void _updateProgress(double progress, String step) {
    processingProgress = progress;
    processingStep = step;
    notifyListeners();
  }

  void _setProcessingState(bool processing) {
    isProcessing = processing;
    if (!processing) {
      processingProgress = 0.0;
      processingStep = '';
    }
    notifyListeners();
  }

  void _resetProcessingState() {
    processingResult = null;
    isProcessing = false;
    processingProgress = 0.0;
    processingStep = '';
    attendanceStats = null;
    _processedFaces.clear();
    notifyListeners();
  }

  // Utility Methods
  String _encodeImageHash(Uint8List imageData) {
    // Implement your image hash encoding logic
    return '';  // Placeholder
  }

  Uint8List _decodeImageHash(String hash) {
    // Implement your image hash decoding logic
    return Uint8List(0);  // Placeholder
  }

  Future<void> saveFaceRecord(ProcessedFace face, String name) async {
    try {
      final record = FaceRecord(
        name: name,
        boxId: boxId,
        embedding: face.embedding,
        createdAt: DateTime.now(),
        imageHash: _encodeImageHash(face.alignedImage),
      );

      await _faceRepo.saveFaceRecord(record);
      await _loadRegisteredFaces(); // Refresh list
      _snackbarService.showSuccess('Face registered successfully');
    } catch (e) {
      _snackbarService.showError('Failed to save face record: $e');
    }
  }

  Future<void> deleteFaceRecord(int faceId) async {
    try {
      await _faceRepo.deleteFaceRecord(faceId);
      await _loadRegisteredFaces(); // Refresh list
      _snackbarService.showSuccess('Face record deleted');
    } catch (e) {
      _snackbarService.showError('Failed to delete face record: $e');
    }
  }

  Future<void> _showRegisterDialog(BuildContext context, ProcessedFace face) async {
    final name = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => RegisterFaceDialog(
        faceImage: face.alignedImage,
        embedding: face.embedding,
      ),
    );

    if (name != null) {
      await saveFaceRecord(face, name);
    }
  }

  // Update the detectAndRegisterFaces method:
  Future<void> detectAndRegisterFaces(BuildContext context) async {
    if (imageOriginalData == null) {
      _snackbarService.showError('Please select an image first');
      return;
    }

    _setProcessingState(true);

    try {
      processingResult = await _faceProcessingService.processImage(
        imageOriginalData!,
        imageSize,
        boxId,
        _period,
        _updateProgress,
      );

      if (!processingResult!.hasDetections) {
        _snackbarService.showError('No faces detected');
        return;
      }

      // Show registration dialog for each new face
      for (final face in processingResult!.processedFaces) {
        if (!face.isRegistered) {
          await _showRegisterDialog(context, face);
        }
      }

    } catch (e) {
      _snackbarService.showError('Face detection failed: $e');
    } finally {
      _setProcessingState(false);
    }
  }
  @override
  void dispose() {
    _registeredFaces.clear();
    _processedFaces.clear();
    super.dispose();
  }
}