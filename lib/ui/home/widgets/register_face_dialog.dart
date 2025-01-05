import 'dart:typed_data';

import 'package:flutter/material.dart';

class RegisterFaceDialog extends StatefulWidget {
  final Uint8List faceImage;
  final List<double> embedding;

  const RegisterFaceDialog({
    super.key,
    required this.faceImage,
    required this.embedding,
  });

  @override
  State<RegisterFaceDialog> createState() => _RegisterFaceDialogState();
}

class _RegisterFaceDialogState extends State<RegisterFaceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Register New Face'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: MemoryImage(widget.faceImage),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter person\'s name',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('CANCEL'),
          onPressed: () => Navigator.pop(context),
        ),
        FilledButton(
          onPressed: _saveFace,
          child: const Text('SAVE'),
        ),
      ],
    );
  }

  void _saveFace() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, _nameController.text.trim());
    }
  }
}
