import 'package:flutter/material.dart';
import 'package:flutterface/ui/home/providers/face_detection_provider.dart';
import 'package:flutterface/ui/home/widgets/empty_registration_state.dart';
import 'package:flutterface/utils/date_formatter.dart';
import 'package:provider/provider.dart';

class RegistrationTabContent extends StatelessWidget {
  const RegistrationTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FaceDetectionProvider>();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRegisteredCount(context, provider),
            const SizedBox(height: 16),
            _buildFacesList(context, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisteredCount(BuildContext context, FaceDetectionProvider provider) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.people_outline,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Registered Faces',
                style: theme.textTheme.titleSmall,
              ),
              Text(
                provider.registeredFacesCount.toString(),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFacesList(BuildContext context, FaceDetectionProvider provider) {
    if (provider.registeredFaces.isEmpty) {
      return const EmptyRegistrationState();
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.registeredFaces.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final face = provider.registeredFaces[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: MemoryImage(face.alignedImage),
          ),
          title: Text(face.name),
          subtitle: Text(DateFormatter.format(face.createdAt)),
        );
      },
    );
  }
}