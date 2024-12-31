import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutterface/services/face_ml/face_ml_service.dart';
import 'package:flutterface/ui/home/providers/face_detection_provider.dart';
import 'package:flutterface/ui/home/widgets/embedding_controls.dart';
import 'package:flutterface/ui/home/widgets/face_detection_view.dart';
import 'package:flutterface/ui/home/widgets/image_controls.dart';
import 'package:provider/provider.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

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
    return ChangeNotifierProvider(
      create: (_) => FaceDetectionProvider(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            widget.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          centerTitle: true,
        ),
        body: const HomePageContent(),
      ),
    );
  }
}

class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          FaceDetectionView(),
          EmbeddingControls(),
          ImageControls(),
        ],
      ),
    );
  }
}
