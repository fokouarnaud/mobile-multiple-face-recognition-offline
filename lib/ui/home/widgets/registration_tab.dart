import 'package:flutter/material.dart';
import 'package:flutterface/ui/home/providers/face_detection_provider.dart';
import 'package:flutterface/ui/home/widgets/empty_registration_state.dart';
import 'package:flutterface/utils/date_formatter.dart';
import 'package:provider/provider.dart';

class RegistrationTab extends StatelessWidget {
  const RegistrationTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FaceDetectionProvider>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStats(context, provider),
          const SizedBox(height: 16),
          _buildFacesList(provider),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context, FaceDetectionProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.people_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Registered Faces',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  provider.registeredFacesCount.toString(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacesList(FaceDetectionProvider provider) {
    if (provider.registeredFaces.isEmpty) {
      return const EmptyRegistrationState();
    }

    return Expanded(
      child: ListView.separated(
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
      ),
    );
  }
}