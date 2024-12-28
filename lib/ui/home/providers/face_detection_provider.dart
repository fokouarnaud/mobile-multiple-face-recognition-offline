import 'dart:developer' as devtools show log;
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutterface/services/face_ml/face_detection/detection.dart';
import 'package:flutterface/services/face_ml/face_ml_service.dart';
import 'package:image_picker/image_picker.dart';

class FaceDetectionProvider extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  final FaceMlService _faceMlService = FaceMlService.instance;

  // State variables
  Image? imageOriginal;
  Image? faceAligned;
  Image? faceAligned2;
  Uint8List? imageOriginalData;
  Uint8List? faceAlignedData;
  Uint8List? faceAlignedData2;
  Size imageSize = const Size(0, 0);
  List<FaceDetectionRelative> faceDetectionResultsRelative = [];
  List<FaceDetectionAbsolute> faceDetectionResultsAbsolute = [];
  List<double> faceEmbeddingResult = [];
  int embeddingStartIndex = 0;
  int faceFocusCounter = 0;
  bool isAnalyzed = false;
  bool isPredicting = false;
  bool isAligned = false;
  bool isEmbedded = false;
  double blurValue = 0;

  int stockImageCounter = 0;
  final List<String> _stockImagePaths = [
    'assets/images/stock_images/one_person.jpeg',
    'assets/images/stock_images/one_person2.jpeg',
    'assets/images/stock_images/one_person3.jpeg',
    'assets/images/stock_images/one_person4.jpeg',
    'assets/images/stock_images/group_of_people.jpeg',
  ];

  // Methods
  Future<void> pickImage(bool fromCamera) async {
    final XFile? image = fromCamera
        ? await _picker.pickImage(source: ImageSource.camera)
        : await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      await _processImage(image);
    }
  }

  Future<void> pickStockImage() async {
    final byteData = await rootBundle.load(_stockImagePaths[stockImageCounter]);
    imageOriginalData = byteData.buffer.asUint8List();
    final decodedImage = await decodeImageFromList(imageOriginalData!);

    imageOriginal = Image.asset(_stockImagePaths[stockImageCounter]);
    imageSize = Size(decodedImage.width.toDouble(), decodedImage.height.toDouble());
    stockImageCounter = (stockImageCounter + 1) % _stockImagePaths.length;
    _resetState();
    notifyListeners();
  }

  Future<void> _processImage(XFile image) async {
    imageOriginalData = await image.readAsBytes();
    final decodedImage = await decodeImageFromList(imageOriginalData!);

    imageOriginal = Image.file(File(image.path));
    imageSize = Size(decodedImage.width.toDouble(), decodedImage.height.toDouble());
    _resetState();
    notifyListeners();
  }

  void _resetState() {
    isAnalyzed = false;
    isPredicting = false;
    isAligned = false;
    isEmbedded = false;
    faceFocusCounter = 0;
    faceDetectionResultsRelative.clear();
    faceDetectionResultsAbsolute.clear();
    faceEmbeddingResult.clear();
    embeddingStartIndex = 0;
  }

  void resetState() {
    _resetState();
    notifyListeners();
  }

  Future<void> detectFaces() async {
    if (imageOriginalData == null || isAnalyzed || isPredicting) return;

    isPredicting = true;
    notifyListeners();

    faceDetectionResultsRelative =
    await _faceMlService.detectFaces(imageOriginalData!);

    faceDetectionResultsAbsolute = relativeToAbsoluteDetections(
      relativeDetections: faceDetectionResultsRelative,
      imageWidth: imageSize.width.round(),
      imageHeight: imageSize.height.round(),
    );

    isPredicting = false;
    isAnalyzed = true;
    notifyListeners();
  }

  Future<void> alignFaces() async {
    if (imageOriginalData == null || !isAnalyzed) return;
    if (faceDetectionResultsAbsolute.isEmpty) {
      devtools.log('No face detected, nothing to align');
      return;
    }
    if (faceDetectionResultsAbsolute.length == 1 && isAligned) {
      devtools.log('This is the only face found in the image');
      return;
    }

    final face = faceDetectionResultsAbsolute[faceFocusCounter];
    try {
      final bothFaces = await _faceMlService
          .alignSingleFaceCustomInterpolation(imageOriginalData!, face);
      faceAlignedData = bothFaces[0];
      faceAlignedData2 = bothFaces[1];

      faceAligned = Image.memory(faceAlignedData!);
      faceAligned2 = Image.memory(faceAlignedData2!);
      isAligned = true;
      faceEmbeddingResult.clear();
      embeddingStartIndex = 0;
      isEmbedded = false;
      faceFocusCounter = (faceFocusCounter + 1) % faceDetectionResultsAbsolute.length;

      notifyListeners();
    } catch (e) {
      devtools.log('Alignment of face failed: $e');
    }
  }

  Future<void> embedFace() async {
    if (!isAligned) return;

    isPredicting = true;
    notifyListeners();

    try {
      final (embeddingResult, isBlurLocal, blurValueLocal) =
      await _faceMlService.embedSingleFace(
        imageOriginalData!,
        faceDetectionResultsRelative[faceFocusCounter],
      );

      faceEmbeddingResult = embeddingResult;
      blurValue = blurValueLocal;
      isEmbedded = true;

      devtools.log('Blur detected: $isBlurLocal, blur value: $blurValueLocal');
    } catch (e) {
      devtools.log('Face embedding failed: $e');
    } finally {
      isPredicting = false;
      notifyListeners();
    }
  }

  void nextEmbedding() {
    embeddingStartIndex = (embeddingStartIndex + 2) % faceEmbeddingResult.length;
    notifyListeners();
  }

  void prevEmbedding() {
    embeddingStartIndex = (embeddingStartIndex - 2) % faceEmbeddingResult.length;
    notifyListeners();
  }
}