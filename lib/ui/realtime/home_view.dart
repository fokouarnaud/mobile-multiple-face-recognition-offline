import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutterface/services/face_ml/face_detection/detection.dart';
import 'package:flutterface/services/face_ml/face_ml_service.dart';
import 'package:flutterface/services/realtime/tflite/recognition.dart';
import 'package:flutterface/services/realtime/tflite/stats.dart';
import 'package:flutterface/ui/realtime/box_widget.dart';
import 'package:flutterface/ui/realtime/camera_view.dart';
import 'package:flutterface/ui/realtime/camera_view_singleton.dart';
import 'package:flutterface/ui/realtime/preview_test.dart';
import 'package:flutterface/utils/face_detection_painter.dart';
import 'dart:typed_data' show Uint8List;

/// [HomeView] stacks [CameraView] and [BoxWidget]s with bottom sheet for stats
class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Use ValueNotifier instead of direct state
  final ValueNotifier<Stats?> statsNotifier = ValueNotifier<Stats?>(null);
  final ValueNotifier<List<Recognition>> resultsNotifier = ValueNotifier<
      List<Recognition>>([]);


  static const BOTTOM_SHEET_RADIUS = Radius.circular(24.0);
  static const BORDER_RADIUS_BOTTOM_SHEET = BorderRadius.only(
    topLeft: BOTTOM_SHEET_RADIUS,
    topRight: BOTTOM_SHEET_RADIUS,
  );

  Uint8List? exampleImageData;

  /// The size of the displayed image (adjusted for screen size).
  late Size imageDisplaySize;

  /// The size of the original image.
  Size imageSize = const Size(0, 0);

  /// Results to draw bounding boxes
  List<Recognition> results = [];

  late List<FaceDetectionAbsolute> faceDetectionResults = <
      FaceDetectionAbsolute>[];

  /// Realtime stats
  Stats? stats;


  /// Initializes the state and loads the Face ML model in the background.
  @override
  void initState() {
    super.initState();
    unawaited(FaceMlService.instance.init());
  }

  @override
  void dispose() {
    statsNotifier.dispose();
    resultsNotifier.dispose();
    super.dispose();
  }

  /// Returns Stack of bounding boxes
  Widget boundingBoxes(List<Recognition> results) {
    if (results.isEmpty) {
      return Container();
    }
    return Stack(
      children: results
          .map(
            (e) =>
            BoxWidget(
              result: e,
              key: UniqueKey(),
            ),
      )
          .toList(),
    );
  }

  /// Callback to get inference results from [CameraView]
  void resultsCallback(List<Recognition> results) {
    // Update value without triggering setState
    resultsNotifier.value = results;
  }


  /// Callback to get inference stats from [CameraView]
  void statsCallback(Stats stats) {
    // Update value without triggering setState
    statsNotifier.value = stats;
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // CameraView won't rebuild when stats change
          CameraView(
            resultsCallback: resultsCallback,
            statsCallback: statsCallback,
          ),

          // Bottom Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: DraggableScrollableSheet(
              initialChildSize: 0.2,
              minChildSize: 0.1,
              maxChildSize: 0.3,
              builder: (_, ScrollController scrollController) =>
                  Container(
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BORDER_RADIUS_BOTTOM_SHEET,
                    ),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.keyboard_arrow_up,
                              size: 48,
                              color: Colors.orange,
                            ),
                            // Use ValueListenableBuilder for stats updates
                            ValueListenableBuilder<Stats?>(
                              valueListenable: statsNotifier,
                              builder: (context, stats, _) {
                                if (stats == null) return Container();
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      StatsRow(
                                        'Inference time:',
                                        '${stats.inferenceTime} ms',
                                      ),
                                      StatsRow(
                                        'Total prediction time:',
                                        '${stats.totalElapsedTime} ms',
                                      ),
                                      StatsRow(
                                        'Pre-processing time:',
                                        '${stats.preProcessingTime} ms',
                                      ),
                                      StatsRow(
                                        'Frame',
                                        '${CameraViewSingleton.inputImageSize
                                            .width} X ${CameraViewSingleton
                                            .inputImageSize.height}',
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Row for one Stats field
class StatsRow extends StatelessWidget {
  final String left;
  final String right;

  const StatsRow(this.left, this.right, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(left), Text(right)],
      ),
    );
  }
}
