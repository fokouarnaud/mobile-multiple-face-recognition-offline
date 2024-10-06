import 'dart:async';
import 'dart:developer' as devtools show log;
import 'dart:io';
import 'dart:typed_data' show Uint8List;
// import 'dart:ui' as ui show Image;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutterface/services/face_ml/face_detection/detection.dart';
import 'package:flutterface/services/face_ml/face_ml_service.dart';
import 'package:flutterface/utils/face_detection_painter.dart';
import 'package:flutterface/utils/image_ml_util.dart';
import 'package:flutterface/utils/snackbar_message.dart';
import 'package:image_picker/image_picker.dart';

/// This widget represents the main page of a Flutter application for face recognition.
class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// Instance for selecting images from the gallery.
  final ImagePicker picker = ImagePicker();

  /// The original image selected by the user.
  Image? imageOriginal;

  /// The image after face alignment using bilinear interpolation.
  Image? faceAligned;

  /// The image after face alignment using bicubic interpolation (for comparison).
  Image? faceAligned2;

  /// The cropped face image.
  Image? faceCropped;

  /// The binary data of the original image.
  Uint8List? imageOriginalData;

  /// The binary data of the aligned face image (bilinear).
  Uint8List? faceAlignedData;

  /// The binary data of the aligned face image (bicubic).
  Uint8List? faceAlignedData2;

  /// The binary data of the cropped face image.
  Uint8List? faceCroppedData;

  /// The size of the original image.
  Size imageSize = const Size(0, 0);

  /// The size of the displayed image (adjusted for screen size).
  late Size imageDisplaySize;

  /// Counter for iterating through stock images.
  int stockImageCounter = 0;

  /// Counter for displaying detected faces one by one.
  int faceFocusCounter = 0;

  /// Index of the currently displayed face (when iterating).
  int showingFaceCounter = 0;

  /// Starting index for displaying embedding values.
  int embeddingStartIndex = 0;

  /// List of paths to stock images stored in the application.
  final List<String> _stockImagePaths = [
    'assets/images/stock_images/one_person.jpeg',
    'assets/images/stock_images/one_person2.jpeg',
    'assets/images/stock_images/one_person3.jpeg',
    'assets/images/stock_images/one_person4.jpeg',
    'assets/images/stock_images/group_of_people.jpeg',
    'assets/images/stock_images/largest_group.jpg',
  ];

  /// Flag indicating if the image has been analyzed (faces detected).
  bool isAnalyzed = false;

  /// Flag indicating if the Face ML model has been loaded. (For internal tracking).
  /// Not used for user interaction.
  bool isBlazeFaceLoaded = false;

  /// Flag indicating if the FaceNet model has been loaded. (For internal tracking).
  /// Not used for user interaction.
  bool isFaceNetLoaded = false;

  /// Flag indicating if a face detection/alignment/embedding process is ongoing.
  bool isPredicting = false;

  /// Flag indicating if a face has been aligned.
  bool isAligned = false;

  /// Flag indicating if a face has been cropped.
  bool isFaceCropped = false;

  /// Flag indicating if the embedding of the face has been calculated.
  bool isEmbedded = false;

  /// List of detected face locations in relative coordinates.
  List<FaceDetectionRelative> faceDetectionResultsRelative = [];

  /// List of detected face locations in absolute coordinates.
  List<FaceDetectionAbsolute> faceDetectionResultsAbsolute = [];

  /// The embedding vector of the aligned face.
  List<double> faceEmbeddingResult = <double>[];

  /// Blur value detected in the image (for informational purposes).
  double blurValue = 0;

  /// Initializes the state and loads the Face ML model in the background.
  @override
  void initState() {
    super.initState();
    unawaited(FaceMlService.instance.init());
  }

  /// Picks an image from the gallery and displays it.
  void _pickImage() async {
    cleanResult();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      imageOriginalData = await image.readAsBytes();
      final stopwatchImageDecoding = Stopwatch()..start();
      final decodedImage = await decodeImageFromList(imageOriginalData!);
      setState(() {
        final imagePath = image.path;

        imageOriginal = Image.file(File(imagePath));
        stopwatchImageDecoding.stop();
        devtools.log(
            'Image decoding took ${stopwatchImageDecoding.elapsedMilliseconds} ms');
        imageSize =
            Size(decodedImage.width.toDouble(), decodedImage.height.toDouble());
      });
    } else {
      devtools.log('No image selected');
    }
  }

  /// Picks an image from the stock and displays it.
  void _stockImage() async {
    cleanResult();
    final byteData = await rootBundle.load(_stockImagePaths[stockImageCounter]);
    imageOriginalData = byteData.buffer.asUint8List();
    final decodedImage = await decodeImageFromList(imageOriginalData!);
    setState(() {
      imageOriginal = Image.asset(_stockImagePaths[stockImageCounter]);
      imageSize =
          Size(decodedImage.width.toDouble(), decodedImage.height.toDouble());
      stockImageCounter = (stockImageCounter + 1) % _stockImagePaths.length;
    });
  }

  // Resets the state of the widget to its initial values.
  ///
  /// This method clears the results, resets counters, and updates the UI to reflect the initial state.
  void cleanResult() {
    isAnalyzed = false;
    faceDetectionResultsAbsolute = <FaceDetectionAbsolute>[];
    faceDetectionResultsRelative = <FaceDetectionRelative>[];
    isAligned = false;
    isFaceCropped = false;
    faceAlignedData = null;
    faceFocusCounter = 0;
    isEmbedded = false;
    embeddingStartIndex = 0;
    faceEmbeddingResult = [];
    setState(() {});
  }

  /// Detects faces in the selected image.
  ///
  /// This method uses the FaceMlService to detect faces in the current image.
  /// If faces are found, the `faceDetectionResults` lists are updated and the `isAnalyzed` flag is set to true.
  void detectFaces() async {
    if (imageOriginalData == null) {
      showResponseSnackbar(context, 'Please select an image first');
      return;
    }
    if (isAnalyzed || isPredicting) {
      return;
    }

    setState(() {
      isPredicting = true;
    });

    faceDetectionResultsRelative =
        await FaceMlService.instance.detectFaces(imageOriginalData!);

    faceDetectionResultsAbsolute = relativeToAbsoluteDetections(
      relativeDetections: faceDetectionResultsRelative,
      imageWidth: imageSize.width.round(),
      imageHeight: imageSize.height.round(),
    );

    setState(() {
      isPredicting = false;
      isAnalyzed = true;
    });
  }
  /// Crops the detected face and displays it.
  ///
  /// This method crops the face at the current `faceFocusCounter` index and displays it.
  /// If there are multiple faces detected, the `faceFocusCounter` can be incremented to crop different faces.
  void cropDetectedFace() async {
    if (imageOriginalData == null) {
      showResponseSnackbar(context, 'Please select an image first');
      return;
    }
    if (!isAnalyzed) {
      showResponseSnackbar(context, 'Please detect faces first');
      return;
    }
    if (faceDetectionResultsAbsolute.isEmpty) {
      showResponseSnackbar(context, 'No face detected, nothing to crop');
      return;
    }
    if (faceDetectionResultsAbsolute.length == 1 && isAligned) {
      showResponseSnackbar(context, 'This is the only face found in the image');
      return;
    }

    final face = faceDetectionResultsAbsolute[faceFocusCounter];
    try {
      final facesList = await generateFaceThumbnails(imageOriginalData!,
          faceDetections: [face]);
      faceCroppedData = facesList[0];
    } catch (e) {
      devtools.log('Alignment of face failed: $e');
      return;
    }

    setState(() {
      isFaceCropped = true;
      faceEmbeddingResult = [];
      embeddingStartIndex = 0;
      isEmbedded = false;
      faceCropped = Image.memory(faceCroppedData!);
      showingFaceCounter = faceFocusCounter;
      faceFocusCounter =
          (faceFocusCounter + 1) % faceDetectionResultsAbsolute.length;
    });
  }

  /// Aligns a single detected face using custom interpolation.
  ///
  /// This method performs face alignment on the currently selected image using
  /// a custom interpolation method. It retrieves the face detection data for the
  /// face at the `faceFocusCounter` index and calls the `alignSingleFaceCustomInterpolation`
  /// method of the `FaceMlService`. If successful, the aligned faces for both bilinear
  /// and bicubic interpolation are stored in `faceAlignedData` and `faceAlignedData2`
  /// respectively. The UI is then updated to reflect the aligned faces and other
  /// internal states are reset.
  void alignFaceCustomInterpolation() async {
    if (imageOriginalData == null) {
      showResponseSnackbar(context, 'Please select an image first');
      return;
    }
    if (!isAnalyzed) {
      showResponseSnackbar(context, 'Please detect faces first');
      return;
    }
    if (faceDetectionResultsAbsolute.isEmpty) {
      showResponseSnackbar(context, 'No face detected, nothing to align');
      return;
    }
    if (faceDetectionResultsAbsolute.length == 1 && isAligned) {
      showResponseSnackbar(context, 'This is the only face found in the image');
      return;
    }

    final face = faceDetectionResultsAbsolute[faceFocusCounter];
    try {
      final bothFaces = await FaceMlService.instance
          .alignSingleFaceCustomInterpolation(imageOriginalData!, face);
      faceAlignedData = bothFaces[0];
      faceAlignedData2 = bothFaces[1];
    } catch (e) {
      devtools.log('Alignment of face failed: $e');
      return;
    }

    setState(() {
      isAligned = true;
      faceEmbeddingResult = [];
      embeddingStartIndex = 0;
      isEmbedded = false;
      faceAligned = Image.memory(faceAlignedData!);
      faceAligned2 = Image.memory(faceAlignedData2!);
      showingFaceCounter = faceFocusCounter;
      faceFocusCounter =
          (faceFocusCounter + 1) % faceDetectionResultsAbsolute.length;
    });
  }

  /// Aligns a single detected face using canvas interpolation.
  ///
  /// This method performs face alignment on the currently selected image using
  /// canvas interpolation. It retrieves the face detection data for the face at
  /// the `faceFocusCounter` index and calls the `alignSingleFaceCanvasInterpolation`
  /// method of the `FaceMlService`. If successful, the aligned face data is stored
  /// in `faceAlignedData`. The UI is then updated to reflect the aligned face and
  /// other internal states are reset.
  void alignFaceCanvasInterpolation() async {
    if (imageOriginalData == null) {
      showResponseSnackbar(context, 'Please select an image first');
      return;
    }
    if (!isAnalyzed) {
      showResponseSnackbar(context, 'Please detect faces first');
      return;
    }
    if (faceDetectionResultsAbsolute.isEmpty) {
      showResponseSnackbar(context, 'No face detected, nothing to align');
      return;
    }
    if (faceDetectionResultsAbsolute.length == 1 && isAligned) {
      showResponseSnackbar(context, 'This is the only face found in the image');
      return;
    }

    final face = faceDetectionResultsAbsolute[faceFocusCounter];
    try {
      faceAlignedData = await FaceMlService.instance
          .alignSingleFaceCanvasInterpolation(imageOriginalData!, face);
    } catch (e) {
      devtools.log('Alignment of face failed: $e');
      return;
    }

    setState(() {
      isAligned = true;
      faceEmbeddingResult = [];
      embeddingStartIndex = 0;
      isEmbedded = false;
      faceAligned = Image.memory(faceAlignedData!);
      showingFaceCounter = faceFocusCounter;
      faceFocusCounter =
          (faceFocusCounter + 1) % faceDetectionResultsAbsolute.length;
    });
  }

  /// Calculates the embedding of the aligned face.
  ///
  /// This method calculates the embedding vector for the currently aligned face.
  /// It retrieves the face detection data for the face at the `showingFaceCounter`
  /// index (which represents the currently displayed face) and calls the
  /// `embedSingleFace` method of the `FaceMlService`. If successful, the embedding
  /// vector and blur value are stored in `faceEmbeddingResult
  void embedFace() async {
    if (isAligned == false) {
      showResponseSnackbar(context, 'Please align face first');
      return;
    }

    setState(() {
      isPredicting = true;
    });

    final (faceEmbeddingResultLocal, isBlurLocal, blurValueLocal) =
        await FaceMlService.instance.embedSingleFace(
      imageOriginalData!,
      faceDetectionResultsRelative[showingFaceCounter],
    );
    faceEmbeddingResult = faceEmbeddingResultLocal;
    blurValue = blurValueLocal;
    devtools.log('Blur detected: $isBlurLocal, blur value: $blurValueLocal');
    // devtools.log('Embedding: $faceEmbeddingResult');

    setState(() {
      isPredicting = false;
      isEmbedded = true;
    });
  }

  /// Navigates to the next embedding value.
  ///
  /// This method increments the `embeddingStartIndex` by 2, effectively
  /// showing the next two values in the embedding vector. It wraps around
  /// to the beginning of the list if the index exceeds the length of
  /// `faceEmbeddingResult`. The UI is then updated to reflect the new embedding
  /// values.
  void nextEmbedding() {
    setState(() {
      embeddingStartIndex =
          (embeddingStartIndex + 2) % faceEmbeddingResult.length;
    });
  }

  /// Navigates to the previous embedding value.
  ///
  /// This method decrements the `embeddingStartIndex` by 2, effectively
  /// showing the previous two values in the embedding vector. It wraps around
  /// to the end of the list if the index goes below zero. The UI is then updated
  /// to reflect the new embedding values.
  void prevEmbedding() {
    setState(() {
      embeddingStartIndex =
          (embeddingStartIndex - 2) % faceEmbeddingResult.length;
    });
  }

  /// Builds the user interface for the home page.
  ///
  /// This method builds the widget tree for the home page. It displays the
  /// selected image, detected faces (if any), aligned faces (if any), and the
  /// calculated embedding vector (if any). It also provides buttons for various
  /// functionalities like picking an image, detecting faces, aligning faces,
  /// calculating embedding, and navigating through the embedding values.
  @override
  Widget build(BuildContext context) {
    imageDisplaySize = Size(
      MediaQuery.of(context).size.width * 0.8,
      MediaQuery.of(context).size.width * 0.8 * 1.5,
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          widget.title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              height: imageDisplaySize.height,
              width: imageDisplaySize.width,
              color: Colors.black,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Image container
                  Center(
                    child: imageOriginal != null
                        ? isAligned
                            ? Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        faceAligned!,
                                        const Text(
                                          'Bilinear',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      children: [
                                        faceAligned2!,
                                        const Text(
                                          'Bicubic',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            : Stack(
                                children: [
                                  imageOriginal!,
                                  if (isAnalyzed)
                                    CustomPaint(
                                      painter: FacePainter(
                                        faceDetections:
                                            faceDetectionResultsAbsolute,
                                        imageSize: imageSize,
                                        availableSize: imageDisplaySize,
                                      ),
                                    ),
                                ],
                              )
                        : const Text(
                            'No image selected',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(
                            Icons.image,
                            color: Colors.black,
                            size: 16,
                          ),
                          label: const Text(
                            'Gallery',
                            style: TextStyle(color: Colors.black, fontSize: 10),
                          ),
                          onPressed: _pickImage,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(50, 30),
                            backgroundColor: Colors.grey[200], // Button color
                            foregroundColor: Colors.black,
                            elevation: 1,
                          ),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(
                            Icons.collections,
                            color: Colors.black,
                            size: 16,
                          ),
                          label: const Text(
                            'Stock',
                            style: TextStyle(color: Colors.black, fontSize: 10),
                          ),
                          onPressed: _stockImage,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(50, 30),
                            backgroundColor: Colors.grey[200], // Button color
                            foregroundColor: Colors.black,
                            elevation: 1, // Elevation (shadow)
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                embeddingStartIndex > 0
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: prevEmbedding,
                      )
                    : const SizedBox(height: 48),
                isEmbedded
                    ? Column(
                        children: [
                          Text(
                            'Embedding: ${faceEmbeddingResult[embeddingStartIndex]}',
                          ),
                          if (embeddingStartIndex + 1 <
                              faceEmbeddingResult.length)
                            Text(
                              '${faceEmbeddingResult[embeddingStartIndex + 1]}',
                            ),
                          Text('Blur: ${blurValue.round()}'),
                        ],
                      )
                    : const SizedBox(height: 48),
                embeddingStartIndex + 2 < faceEmbeddingResult.length
                    ? IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: nextEmbedding,
                      )
                    : const SizedBox(height: 48),
              ],
            ),
            ElevatedButton.icon(
              icon: isAnalyzed
                  ? const Icon(Icons.person_remove_outlined)
                  : const Icon(Icons.people_alt_outlined),
              label: isAnalyzed
                  ? const Text('Clean result')
                  : const Text('Detect faces'),
              onPressed: isAnalyzed ? cleanResult : detectFaces,
            ),
            isAnalyzed
                ? ElevatedButton.icon(
                    icon: const Icon(Icons.face_retouching_natural),
                    label: const Text('Align faces'),
                    onPressed: alignFaceCustomInterpolation,
                  )
                : const SizedBox.shrink(),
            (isAligned && !isEmbedded)
                ? ElevatedButton.icon(
                    icon: const Icon(Icons.numbers_outlined),
                    label: const Text('Embed face'),
                    onPressed: embedFace,
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
