import 'package:flutter/material.dart';

class EmptyStateView extends StatelessWidget {
  const EmptyStateView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_enhance,
            size: 64,
            color: theme.colorScheme.onSurface.withAlpha(76),
          ),
          const SizedBox(height: 16),
          Text(
            'No Image Selected',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(178),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Take a photo or select from gallery',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(127),
            ),
          ),
        ],
      ),
    );
  }
}