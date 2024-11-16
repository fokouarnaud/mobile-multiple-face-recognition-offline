import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data' show Uint8List;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutterface/services/face_ml/face_detection/detection.dart';
import 'package:flutterface/services/face_ml/face_ml_service.dart';
//import 'package:flutterface/services/face_ml/face_ml_service.dart';
import 'package:flutterface/services/realtime/tflite/recognition.dart';
import 'package:flutterface/services/realtime/tflite/stats.dart';
import 'package:flutterface/ui/realtime/camera_view_singleton.dart';
import 'package:flutterface/utils/image_ml_util.dart';
//import 'package:flutterface/utils/realtime/isolate_utils.dart';
import 'package:flutterface/utils/snackbar_message.dart';

/// [CameraView] sends each frame for inference
class CameraView extends StatefulWidget {
  /// Callback to pass results after inference to [HomeView]
  final Function(List<Recognition> recognitions) resultsCallback;

  /// Callback to inference stats to [HomeView]
  final Function(Stats stats) statsCallback;

  /// Constructor
  const CameraView({
    required this.resultsCallback,
    required this.statsCallback,
    super.key,
  });

  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver {



  /// List of available cameras
  List<CameraDescription> cameras = [];

  /// Controller
  CameraController? _cameraController;

  /// true when inference is ongoing
  bool predicting = false;

  /// List of detected face locations in relative coordinates.
  List<FaceDetectionRelative> faceDetectionResultsRelative = [];

  /// List of detected face locations in absolute coordinates.
  List<FaceDetectionAbsolute> faceDetectionResultsAbsolute = [];

  /// Instance of [Classifier]
  // late Classifier classifier;

  /// Instance of [IsolateUtils]
  // late IsolateUtils isolateUtils;

  @override
  void initState() {
    super.initState();
    initStateAsync();
  }

  void initStateAsync() async {
    WidgetsBinding.instance.addObserver(this);
    try {
      /// Camera initialization
      await _setupCameraController();

      // Create an instance of classifier to load model and labels
      //classifier = Classifier();
      ///loads the Face ML model in the background
      // unawaited(FaceMlService.instance.init());
    } catch (e) {
      // Store error message to show later
      final errorMessage = 'Initialization Error: ${e.toString()}';
      if (mounted) {
        showResponseSnackbar(context, errorMessage);
      }
    }
    // Spawn a new isolate
    // isolateUtils = IsolateUtils();
    //await isolateUtils.start();


  }

  /// Initializes the camera by setting [cameraController]
  Future<void> _setupCameraController() async {
    final List<CameraDescription> _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {

        _cameraController = CameraController(
          _cameras[1],
          ResolutionPreset.low, // Instead of ResolutionPreset.low,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.bgra8888, // Optimize for processing
        );


      await _cameraController?.initialize().then((_) async {

        if (!mounted) {
          return;
        }
        // Stream of image passed to [onLatestImageAvailable] callback
        await _cameraController?.startImageStream(onLatestImageAvailable);

        /// previewSize is size of each image frame captured by controller
        ///
        /// 352x288 on iOS, 240p (320x240) on Android with ResolutionPreset.low
        final Size? previewSize = _cameraController?.value.previewSize;

        /// previewSize is size of raw input image to the model
        CameraViewSingleton.inputImageSize = previewSize!;

        // the display width of image on screen is
        // same as screenWidth while maintaining the aspectRatio
        final Size screenSize = MediaQuery.of(context).size;
        CameraViewSingleton.screenSize = screenSize;
        CameraViewSingleton.ratio = screenSize.width / previewSize.height;
        setState(() {});
      }).catchError((Object e) {
        if (e is CameraException) {
          switch (e.code) {
            case 'CameraAccessDenied':
              showResponseSnackbar(context, 'CameraAccessDenied');
              break;
            default:
              showResponseSnackbar(context, 'Camera Unexpected Error');
              break;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Return empty container while the camera is not initialized
    if (_cameraController == null ||
        _cameraController?.value.isInitialized == false) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    /*
     return AspectRatio(
       aspectRatio: cameraController!.value.aspectRatio,
      child: CameraPreview(
        cameraController!,
      ),
    );

     */

  return AspectRatio(
      aspectRatio:  _cameraController!.value.aspectRatio ,
      child: ClipRect(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _cameraController!.value.previewSize!.height,
            height: _cameraController!.value.previewSize!.width,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(math.pi),
              child: CameraPreview(_cameraController!),
            ),
          ),
        ),
      ),
    );



  }


  /// Callback to receive each frame [CameraImage] perform inference on it
  Future onLatestImageAvailable(CameraImage cameraImage) async {
    if (predicting) return;

    setState(() {
      predicting = true;
    });

    try {
      //showResponseSnackbar(context, 'TODO:classifier');
      final uiThreadTimeStart = DateTime.now().millisecondsSinceEpoch;

      // Data to be passed to inference isolate
      //final resultaOne = convertCameraImage(cameraImage);
     // final resultTwo = resultaOne.buffer;

    final Uint8List imageOriginalData = await cameraImageToUint8List(cameraImage);

    faceDetectionResultsRelative =
        await FaceMlService.instance.detectFaces(imageOriginalData!);
    final imageSize = Size(
      _cameraController!.value.previewSize!.width.toDouble(),
      _cameraController!.value.previewSize!.height.toDouble(),
    );
    faceDetectionResultsAbsolute = relativeToAbsoluteDetections(
      relativeDetections: faceDetectionResultsRelative,
      imageWidth: imageSize.width.round(),
      imageHeight: imageSize.height.round(),
    );

      final uiThreadInferenceElapsedTime =
          DateTime.now().millisecondsSinceEpoch - uiThreadTimeStart;

      //final List<Recognition> recognitionsResults =
      //    faceDetectionResultsAbsolute.map((e) => e.toRecognition()).toList();

      // pass results to HomeView
      //widget.resultsCallback(recognitionsResults);

      // pass stats to HomeView
      widget.statsCallback(
           Stats(
            preProcessingTime: 0,
            inferenceTime: 0,
            totalPredictTime: 0,
            totalElapsedTime: 0,
          )..totalElapsedTime = uiThreadInferenceElapsedTime,
        //  imageOriginalData
      );

    } catch (e) {
      final errorMessage = 'Inference Error: ${e.toString()}';
      // Only show Snackbar if mounted
      if (mounted) {
        showResponseSnackbar(context, errorMessage);
      }
    } finally {
      // Reset predicting flag regardless of success or failure
      if (mounted) {
        setState(() {
          predicting = false;
        });
      }
    }

  }


  /// Runs inference in another isolate
  /* Future<Map<String, dynamic>> inference(IsolateData isolateData) async {
    ReceivePort responsePort = ReceivePort();
    isolateUtils.sendPort
        .send(isolateData..responsePort = responsePort.sendPort);
    var results = await responsePort.first;
    return results;
  }*/



  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    // App state changed before we got the chance to initialize.

    switch (state) {
      //case AppLifecycleState.inactive:
      //  await cameraController.dispose();
      //  break;
      case AppLifecycleState.paused:
        await _cameraController?.stopImageStream();
        break;
      case AppLifecycleState.resumed:
        if (_cameraController?.value.isStreamingImages == false) {
          await _cameraController?.startImageStream(onLatestImageAvailable);
        }
        break;
      default:
    }
  }

  @override
  void dispose() {

    // Cancel any active timers or listeners
    _cameraController?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
