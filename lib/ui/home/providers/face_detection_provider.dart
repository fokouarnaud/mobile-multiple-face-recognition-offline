import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterface/models/face_processing_result.dart';
import 'package:flutterface/services/face_processing/face_processing_service.dart';
import 'package:flutterface/services/image/stock_image_service.dart';
import 'package:flutterface/services/snackbar/snackbar_service.dart';
import 'package:flutterface/ui/home/widgets/new_face_dialog.dart';
import 'package:image_picker/image_picker.dart';

class FaceDetectionProvider extends ChangeNotifier {
  // Constructor and Dependencies
  FaceDetectionProvider({required this.boxId});

  final int boxId;
  final ImagePicker _picker = ImagePicker();
  final FaceProcessingService _faceProcessingService = FaceProcessingService.instance;
  final StockImageService _stockImageService = StockImageService.instance;
  final SnackbarService _snackbarService = SnackbarService.instance;

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

  // Public Methods
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
      await _processStockImage(imageData, path);

      stockImageCounter = (stockImageCounter + 1) % _stockImageService.stockImagePaths.length;
    } catch (e) {
      _snackbarService.showError('Failed to load stock image: $e');
    }
  }

  Future<void> processAndSaveFaces(BuildContext context) async {
    if (imageOriginalData == null) {
      _snackbarService.showError('Please select an image first');
      return;
    }

    _initializeProcessing();

    try {
      processingResult = await _faceProcessingService.processImage(
        imageOriginalData!,
        imageSize,
        boxId,
        onProgress: _updateProgress,
        onNewFace: (faceImage, embedding) => _handleNewFace(context, faceImage, embedding),
      );

      _showResultSnackbar();
    } catch (e) {
      _snackbarService.showError('Face processing failed: $e');
    } finally {
      await _finalizeProcessing();
    }
  }

  void resetState() {
    imageOriginal = null;
    imageOriginalData = null;
    imageSize = const Size(0, 0);
    _resetProcessingState();
  }

  // Private Methods - Image Processing
  Future<void> _processImage(XFile image) async {
    try {
      imageOriginalData = await image.readAsBytes();
      await _updateImageState(
        File(image.path),
        imageOriginalData!,
      );
    } catch (e) {
      _snackbarService.showError('Failed to process image: $e');
    }
  }

  Future<void> _processStockImage(Uint8List imageData, String path) async {
    imageOriginalData = imageData;
    await _updateImageState(
      null,
      imageOriginalData!,
      assetPath: path,
    );
  }

  Future<void> _updateImageState(
      File? file,
      Uint8List imageData, {
        String? assetPath,
      }) async {
    final decodedImage = await decodeImageFromList(imageData);

    imageOriginal = assetPath != null
        ? Image.asset(assetPath)
        : Image.file(file!);

    imageSize = Size(
      decodedImage.width.toDouble(),
      decodedImage.height.toDouble(),
    );

    notifyListeners();
  }

  // Private Methods - Processing State Management
  void _resetProcessingState() {
    processingResult = null;
    isProcessing = false;
    processingProgress = 0.0;
    processingStep = '';
    notifyListeners();
  }

  void _initializeProcessing() {
    processingResult = null;
    isProcessing = true;
    processingProgress = 0.0;
    processingStep = 'Initializing...';
    notifyListeners();
  }

  Future<void> _finalizeProcessing() async {
    await Future.delayed(const Duration(milliseconds: 200));
    isProcessing = false;
    processingProgress = 0;
    processingStep = '';
    notifyListeners();
  }

  void _updateProgress(double progress, String step) {
    processingProgress = progress;
    processingStep = step;
    notifyListeners();
  }

  // Private Methods - UI Callbacks
  Future<String?> _handleNewFace(
      BuildContext context,
      Uint8List faceImage,
      List<double> embedding,
      ) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => NewFaceDialog(
        faceImage: faceImage,
        embedding: embedding,
      ),
    );
  }

  void _showResultSnackbar() {
    if (processingResult == null || !processingResult!.hasDetections) {
      _snackbarService.showError('No faces detected');
      return;
    }

    final totalFaces = processingResult!.totalFaces;
    final registeredFaces = processingResult!.registeredFaces;
    final newFaces = processingResult!.newFaces;

    if (registeredFaces > 0 && newFaces > 0) {
      _snackbarService.showSuccess(
        '$totalFaces faces detected ($registeredFaces registered, $newFaces new)',
      );
    } else if (registeredFaces > 0) {
      _snackbarService.showSuccess(
        '$totalFaces registered faces detected',
      );
    } else {
      _snackbarService.showSuccess(
        '$totalFaces new faces detected',
      );
    }
  }
}