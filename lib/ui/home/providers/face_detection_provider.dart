import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterface/models/face_processing_result.dart';
import 'package:flutterface/services/face_processing/face_processing_service.dart';
import 'package:flutterface/services/image/stock_image_service.dart';
import 'package:flutterface/services/snackbar/snackbar_service.dart';
import 'package:image_picker/image_picker.dart';


class FaceDetectionProvider extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  final FaceProcessingService _faceProcessingService = FaceProcessingService.instance;
  final StockImageService _stockImageService = StockImageService.instance;
  final _snackbarService = SnackbarService.instance;

  // State variables
  Image? imageOriginal;
  Uint8List? imageOriginalData;
  Size imageSize = const Size(0, 0);
  FaceProcessingResult? processingResult;
  bool isProcessing = false;
  int stockImageCounter = 0;

  Future<void> pickImage(bool fromCamera) async {
    processingResult = null;
    final XFile? image = fromCamera
        ? await _picker.pickImage(source: ImageSource.camera)
        : await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      await _processImage(image);
    }
  }

  Future<void> pickStockImage() async {
    try {
      processingResult = null;
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

  void _showResultSnackbar() {
    if (processingResult == null || processingResult!.detections.isEmpty) {
      _snackbarService.showError('No faces detected');
    } else {
      _snackbarService.showSuccess('${processingResult!.detections.length} faces detected');
    }
  }

  Future<void> processAndSaveFaces() async {
    if (imageOriginalData == null) {
      _snackbarService.showError('Please select an image first');
      return;
    }

    processingResult = null;
    isProcessing = true;
    notifyListeners();

    try {
      processingResult = await _faceProcessingService.processImage(
        imageOriginalData!,
        imageSize,
      );
      _showResultSnackbar();
    } catch (e) {
      _snackbarService.showError('Face processing failed: $e');
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }

  void resetState() {
    imageOriginal = null;
    imageOriginalData = null;
    imageSize = const Size(0, 0);
    processingResult = null;
    isProcessing = false;
    notifyListeners();
  }
}
