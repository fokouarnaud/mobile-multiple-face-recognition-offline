
import 'dart:typed_data';

import 'package:flutter/material.dart';

class NewFaceDialog extends StatefulWidget {
  final Uint8List faceImage;
  final List<double> embedding;

  const NewFaceDialog({
    required this.faceImage,
    required this.embedding,
    super.key,
  });

  @override
  State<NewFaceDialog> createState() => _NewFaceDialogState();
}

class _NewFaceDialogState extends State<NewFaceDialog> {
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Face Detected'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                widget.faceImage,
                height: 150,
                width: 150,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, _nameController.text);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}