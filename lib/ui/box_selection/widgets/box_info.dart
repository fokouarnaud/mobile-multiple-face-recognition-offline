import 'package:flutter/material.dart';
import 'package:flutterface/models/box_with_stats.dart';
import 'package:flutterface/utils/date_formatter.dart';

class BoxInfo extends StatelessWidget {
  final BoxWithStats box;

  const BoxInfo({super.key, required this.box});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          box.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          box.description,
          style: theme.textTheme.bodyMedium,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          'Last updated: ${DateFormatter.format(box.lastUpdated)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
