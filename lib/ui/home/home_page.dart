import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutterface/config/routes.dart';
import 'package:flutterface/services/face_ml/face_ml_service.dart';
import 'package:flutterface/ui/home/home_page_content.dart';
import 'package:flutterface/ui/home/providers/face_detection_provider.dart';
import 'package:flutterface/ui/home/widgets/info_dialog.dart';

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
        create: (_) => FaceDetectionProvider(
          boxId: widget.boxId,
          period: DateTime.now().hour,
        ),
        child: Scaffold(
          appBar: _buildAppBar(context),
          body: const HomePageContent(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () async => Routes.navigateToRoot(context),
      ),
      title: Text(
        widget.title,
        style: theme.textTheme.headlineSmall,
      ),
      centerTitle: true,
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: _showInfoDialog,
        ),
      ],
    );
  }



  Future<void> _showInfoDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => const InfoDialog(),
    );
  }
}