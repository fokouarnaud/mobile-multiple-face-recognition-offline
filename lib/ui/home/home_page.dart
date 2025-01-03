import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutterface/config/routes.dart';
import 'package:flutterface/services/face_ml/face_ml_service.dart';
import 'package:flutterface/ui/home/providers/face_detection_provider.dart';
import 'package:flutterface/ui/home/widgets/custom_bottom_sheet.dart';
import 'package:flutterface/ui/home/widgets/face_detection_view.dart';
import 'package:flutterface/ui/home/widgets/image_controls.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  final String title;
  final int boxId;

  const HomePage({
    super.key,
    required this.title,
    required this.boxId,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    unawaited(FaceMlService.instance.init());
  }


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await Routes.navigateToRoot(context);
        }
      },
      child: ChangeNotifierProvider(
        create: (_) => FaceDetectionProvider(boxId: widget.boxId),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async => Routes.navigateToRoot(context),
            ),
            title: Text(
              widget.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            centerTitle: true,
          ),
          body: const HomePageContent(),
        ),
      ),
    );
  }
}
class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              FaceDetectionView(),
              SizedBox(height: 16.0),
              ImageControls(),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: CustomBottomSheet(),
        ),
      ],
    );
  }
}
