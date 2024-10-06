import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
//import 'package:flutterface/services/realtime/tflite/classifier.dart';
import 'package:flutterface/services/realtime/tflite/recognition.dart';
import 'package:flutterface/services/realtime/tflite/stats.dart';
import 'package:flutterface/ui/realtime/camera_view_singleton.dart';
//import 'package:flutterface/utils/realtime/isolate_utils.dart';
import 'package:flutterface/utils/snackbar_message.dart';

/// [CameraView] sends each frame for inference
class CameraView extends StatefulWidget {
  /// Callback to pass results after inference to [HomeView]
  final Function(List<Recognition> recognitions) resultsCallback;

  /// Callback to inference stats to [HomeView]
  final Function(Stats stats) statsCallback;

  final List<CameraDescription> cameras;

  /// Constructor
  const CameraView({
    required this.cameras,
    required this.resultsCallback,
    required this.statsCallback,
    super.key,
  });

  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver {
  /// Controller
  late CameraController cameraController;

  /// true when inference is ongoing
  late bool predicting;

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

    // Spawn a new isolate
    // isolateUtils = IsolateUtils();
    //await isolateUtils.start();

    // Camera initialization
    initializeCamera();

    // Create an instance of classifier to load model and labels
    //classifier = Classifier();

    // Initially predicting = false
    predicting = false;
  }

  /// Initializes the camera by setting [cameraController]
  void initializeCamera() async {
    // cameras[0] for rear-camera
    cameraController = CameraController(widget.cameras[0], ResolutionPreset.low,
        enableAudio: false);

    await cameraController.initialize().then((_) async {
      if (!mounted) {
        return;
      }
      // Stream of image passed to [onLatestImageAvailable] callback
      await cameraController.startImageStream(onLatestImageAvailable);

      /// previewSize is size of each image frame captured by controller
      ///
      /// 352x288 on iOS, 240p (320x240) on Android with ResolutionPreset.low
      Size? previewSize = cameraController.value.previewSize;

      /// previewSize is size of raw input image to the model
      CameraViewSingleton.inputImageSize = previewSize!;

      // the display width of image on screen is
      // same as screenWidth while maintaining the aspectRatio
      Size screenSize = MediaQuery.of(context).size;
      CameraViewSingleton.screenSize = screenSize;
      CameraViewSingleton.ratio = screenSize.width / previewSize.height;
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

  @override
  Widget build(BuildContext context) {
    // Return empty container while the camera is not initialized
    if (cameraController == null || !cameraController.value.isInitialized) {
      return Container();
    }

    return AspectRatio(
        aspectRatio: cameraController.value.aspectRatio,
        child: CameraPreview(cameraController));
  }

  /// Callback to receive each frame [CameraImage] perform inference on it
  onLatestImageAvailable(CameraImage cameraImage) async {
    showResponseSnackbar(context, 'TODO:classifier');

    ///todo:foreach frame process
    /* if (classifier.interpreter != null && classifier.labels != null) {
      // If previous inference has not completed then return
      if (predicting) {
        return;
      }

      setState(() {
        predicting = true;
      });

      var uiThreadTimeStart = DateTime.now().millisecondsSinceEpoch;

      // Data to be passed to inference isolate
      var isolateData = IsolateData(
          cameraImage, classifier.interpreter.address, classifier.labels);

      // We could have simply used the compute method as well however
      // it would be as in-efficient as we need to continuously passing data
      // to another isolate.

      /// perform inference in separate isolate
      Map<String, dynamic> inferenceResults = await inference(isolateData);

      var uiThreadInferenceElapsedTime =
          DateTime.now().millisecondsSinceEpoch - uiThreadTimeStart;

      // pass results to HomeView
      widget.resultsCallback(inferenceResults["recognitions"]);

      // pass stats to HomeView
      widget.statsCallback((inferenceResults["stats"] as Stats)
        ..totalElapsedTime = uiThreadInferenceElapsedTime);

      // set predicting to false to allow new frames
      setState(() {
        predicting = false;
      });
    }*/
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
        await cameraController.stopImageStream();
        break;
      case AppLifecycleState.resumed:
        if (!cameraController.value.isStreamingImages) {
          await cameraController.startImageStream(onLatestImageAvailable);
        }
        break;
      default:
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cameraController.dispose();
    super.dispose();
  }
}
