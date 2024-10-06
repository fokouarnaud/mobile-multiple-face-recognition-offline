import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutterface/services/realtime/tflite/recognition.dart';
import 'package:flutterface/services/realtime/tflite/stats.dart';
import 'package:flutterface/ui/realtime/box_widget.dart';
import 'package:flutterface/ui/realtime/camera_view.dart';
import 'package:flutterface/ui/realtime/camera_view_singleton.dart';


/// [HomeView] stacks [CameraView] and [BoxWidget]s with bottom sheet for stats
class HomeView extends StatefulWidget {
  final List<CameraDescription> cameras;

  const HomeView({required this.cameras, super.key});

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  static const BOTTOM_SHEET_RADIUS = Radius.circular(24.0);
  static const BORDER_RADIUS_BOTTOM_SHEET = BorderRadius.only(
    topLeft: BOTTOM_SHEET_RADIUS,
    topRight: BOTTOM_SHEET_RADIUS,
  );


  /// Results to draw bounding boxes
  late List<Recognition> results;

  /// Realtime stats
  Stats? stats;


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
    setState(() {
      this.results = results;
    });
  }

  /// Callback to get inference stats from [CameraView]
  void statsCallback(Stats stats) {
    setState(() {
      this.stats = stats;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: UniqueKey(),
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          // Camera View
          CameraView(resultsCallback: resultsCallback,
            statsCallback: statsCallback,
            cameras: widget.cameras),
          // Bounding boxes
          // boundingBoxes(results),

          // Heading
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                'Object Detection Flutter',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrangeAccent.withOpacity(0.6),
                ),
              ),
            ),
          ),

          // Bottom Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: DraggableScrollableSheet(
              initialChildSize: 0.4,
              minChildSize: 0.1,
              maxChildSize: 0.5,
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
                            (stats != null)
                                ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  StatsRow(
                                    'Inference time:',
                                    '${stats?.inferenceTime} ms',
                                  ),
                                  StatsRow(
                                    'Total prediction time:',
                                    '${stats?.totalElapsedTime} ms',
                                  ),
                                  StatsRow(
                                    'Pre-processing time:',
                                    '${stats?.preProcessingTime} ms',
                                  ),
                                  StatsRow(
                                    'Frame',
                                    '${CameraViewSingleton.inputImageSize
                                        .width} X ${CameraViewSingleton
                                        .inputImageSize.height}',
                                  ),
                                ],
                              ),
                            )
                                : Container(),
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
