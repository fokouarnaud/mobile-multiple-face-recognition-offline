import 'package:flutter/material.dart';
import 'package:flutterface/models/face_record.dart';
import 'package:flutterface/ui/home/providers/face_detection_provider.dart';
import 'package:provider/provider.dart';

class FaceRegistrationList extends StatelessWidget {
  const FaceRegistrationList({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FaceDetectionProvider>();

    if (provider.registeredFaces.isEmpty) {
      return const Center(
        child: Text('No faces registered yet'),
      );
    }

    return ListView.builder(
      itemCount: provider.registeredFaces.length,
      itemBuilder: (context, index) {
        final face = provider.registeredFaces[index];
        return Card(
          margin: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: MemoryImage(face.alignedImage),
            ),
            title: Text(face.name),
            subtitle: Text('Registered on: ${_formatDate(face.createdAt)}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context, provider, face),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _confirmDelete(BuildContext context, FaceDetectionProvider provider, FaceRecord face) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Face Record'),
        content: Text('Are you sure you want to delete ${face.name}?'),
        actions: [
          TextButton(
            child: const Text('CANCEL'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text(
              'DELETE',
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () async {
              await provider.deleteFaceRecord(face.id!);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}