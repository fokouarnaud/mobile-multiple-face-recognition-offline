import 'package:flutter/material.dart';
import 'package:flutterface/models/box_with_stats.dart';

class BoxMenu extends StatelessWidget {
  final BoxWithStats box;
  final Function(String) onSelected;

  const BoxMenu({
    super.key,
    required this.box,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: onSelected,
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined),
              SizedBox(width: 8),
              Text('Edit'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              const Icon(Icons.delete_outline, color: Colors.red),
              const SizedBox(width: 8),
              Text(
                'Delete',
                style: TextStyle(color: Colors.red[700]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}