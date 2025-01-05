import 'package:flutter/material.dart';

class EmptyRegistrationState extends StatelessWidget {
  const EmptyRegistrationState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_add_outlined,
              size: 64,
              color: theme.colorScheme.primary.withAlpha(76),
            ),
            const SizedBox(height: 16),
            Text(
              'No Registered Faces',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(178),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Take a photo or select an image to register new faces',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(127),
              ),
            ),
            const SizedBox(height: 24),
            _buildInstructionsList(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsList(ThemeData theme) {
    return Column(
      children: [
        _buildInstructionStep(
          theme,
          '1',
          'Select an image with clear faces',
          Icons.image_search,
        ),
        const SizedBox(height: 16),
        _buildInstructionStep(
          theme,
          '2',
          'Faces will be detected automatically',
          Icons.face_retouching_natural,
        ),
        const SizedBox(height: 16),
        _buildInstructionStep(
          theme,
          '3',
          'Enter names for each detected face',
          Icons.drive_file_rename_outline,
        ),
      ],
    );
  }

  Widget _buildInstructionStep(
      ThemeData theme,
      String number,
      String text,
      IconData icon,
      ) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.primary.withAlpha(127),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(178),
            ),
          ),
        ),
      ],
    );
  }
}