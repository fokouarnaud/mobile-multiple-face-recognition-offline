// lib/ui/widgets/info_dialog.dart

import 'package:flutter/material.dart';

class InfoDialog extends StatelessWidget {
  const InfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('How to Use'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSection(
              theme,
              'Register Faces',
              '1. Take a photo or select from gallery\n'
                  '2. The app will detect faces automatically\n'
                  '3. Enter names for new faces\n'
                  '4. Faces will be saved for attendance',
              Icons.how_to_reg_outlined,
            ),
            const Divider(height: 32),
            _buildSection(
              theme,
              'Check Attendance',
              '1. Take a photo of the group\n'
                  '2. App will detect and match faces\n'
                  '3. View attendance statistics\n'
                  '4. Check present and absent lists',
              Icons.fact_check_outlined,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Got it'),
        ),
      ],
    );
  }

  Widget _buildSection(
      ThemeData theme,
      String title,
      String content,
      IconData icon,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}