import 'package:flutter/material.dart';
import 'package:flutterface/ui/home/providers/face_detection_provider.dart';
import 'package:flutterface/ui/shared/buttons/custom_button.dart';
import 'package:flutterface/utils/date_formatter.dart';
import 'package:provider/provider.dart';

class RegisterTab extends StatelessWidget {
  const RegisterTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FaceDetectionProvider>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStats(context, provider),
          const SizedBox(height: 16),
          _buildRegisterButton(context, provider),
          const SizedBox(height: 16),
          Expanded(child: _buildRegisteredList(context, provider)),
        ],
      ),
    );
  }

  Widget _buildRegisteredList(
    BuildContext context,
    FaceDetectionProvider provider,
  ) {
    return ListView.builder(
      itemCount: provider.registeredFaces.length,
      itemBuilder: (context, index) {
        final face = provider.registeredFaces[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: MemoryImage(face.alignedImage),
          ),
          title: Text(face.name),
          subtitle: Text(
            'Registered: ${DateFormatter.format(face.createdAt)}',
          ), // Using DateFormatter here
        );
      },
    );
  }

  Widget _buildStats(BuildContext context, FaceDetectionProvider provider) {
    return Row(
      children: [
        Icon(
          Icons.people_outline,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          'Registered Faces: ${provider.registeredFacesCount}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }

  Widget _buildRegisterButton(
    BuildContext context,
    FaceDetectionProvider provider,
  ) {
    return CustomButton(
      icon: Icons.person_add_outlined,
      label: 'Detect & Register Faces',
      size: ButtonSize.lg,
      onPressed: provider.isProcessing
          ? null
          : () async => provider.detectAndRegisterFaces(context),
    );
  }
}
