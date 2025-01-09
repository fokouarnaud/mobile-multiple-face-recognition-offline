
import 'package:flutter/material.dart';
import 'package:flutterface/models/face_record.dart';

class EditFaceDialog extends StatefulWidget {
  final FaceRecord face;

  const EditFaceDialog({super.key, required this.face});

  @override
  EditFaceDialogState createState() => EditFaceDialogState();
}

class EditFaceDialogState extends State<EditFaceDialog> {
  late TextEditingController _nameController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.face.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Face Name'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a name';
            }
            return null;
          },
          autofocus: true,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, true);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}