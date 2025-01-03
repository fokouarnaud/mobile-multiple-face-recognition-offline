
import 'package:flutter/material.dart';
import 'package:flutterface/config/routes.dart';
import 'package:flutterface/models/box_with_stats.dart';
import 'package:flutterface/ui/box_selection/widgets/box_info.dart';
import 'package:flutterface/ui/box_selection/widgets/box_menu.dart';
import 'package:flutterface/ui/box_selection/widgets/face_counter.dart';

class BoxCard extends StatelessWidget {
  final BoxWithStats box;
  final Function(BuildContext, String, BoxWithStats) onMenuAction;

  const BoxCard({
    super.key,
    required this.box,
    required this.onMenuAction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      child: InkWell(
        onTap: () => Routes.navigateToHome(context, box.id, box.name),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              FaceCounter(count: box.faceCount),
              const SizedBox(width: 16),
              Expanded(child: BoxInfo(box: box)),
              BoxMenu(
                box: box,
                onSelected: (value) => onMenuAction(context, value, box),
              ),
            ],
          ),
        ),
      ),
    );
  }
}