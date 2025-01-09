// lib/ui/home/home_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutterface/config/routes.dart';
import 'package:flutterface/services/face_ml/face_ml_service.dart';
import 'package:flutterface/ui/home/providers/face_detection_provider.dart';
import 'package:flutterface/ui/home/widgets/face_detection_view.dart';
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
  int _selectedIndex = 0;

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
          body: SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: FaceDetectionView(
                    isRegistrationMode: _selectedIndex == 0,
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNav(),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async => Routes.navigateToRoot(context),
          ),
          Expanded(
            child: Text(
              widget.title,
              style: theme.textTheme.titleLarge,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final theme = Theme.of(context);

    return NavigationBar(
      height: 60,
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) => setState(() => _selectedIndex = index),
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.person_add_outlined),
          selectedIcon:
              Icon(Icons.person_add, color: theme.colorScheme.primary),
          label: 'Register',
        ),
        NavigationDestination(
          icon: const Icon(Icons.fact_check_outlined),
          selectedIcon:
              Icon(Icons.fact_check, color: theme.colorScheme.primary),
          label: 'Attendance',
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
