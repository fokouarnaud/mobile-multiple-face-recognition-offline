import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class Uint8ListImageDisplay extends StatelessWidget {
  final Uint8List? imageData;

  const Uint8ListImageDisplay({super.key, required this.imageData});

  @override
  Widget build(BuildContext context) {
    if (imageData == null) {
      return Container();
    }

    final decodedImage = img.decodeImage(imageData!);
    print('Image data length: ${imageData!.length}'); // Debugging line

    return Center(
      child: decodedImage != null
          ? Image.memory(imageData!) // Use Image.memory to display the image
          : const Text('Failed to load image', style: TextStyle(color: Colors.red)),
    );
  }
}
