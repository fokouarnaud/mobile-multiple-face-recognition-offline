import 'package:flutter/material.dart';
import 'package:flutterface/ui/home/providers/face_detection_provider.dart';
import 'package:provider/provider.dart';

class EmbeddingControls extends StatelessWidget {
  const EmbeddingControls({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FaceDetectionProvider>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        provider.embeddingStartIndex > 0
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: provider.prevEmbedding,
        )
            : const SizedBox(height: 48),
        if (provider.isEmbedded)
          Column(
            children: [
              Text(
                'Embedding: ${provider.faceEmbeddingResult[provider.embeddingStartIndex]}',
              ),
              if (provider.embeddingStartIndex + 1 <
                  provider.faceEmbeddingResult.length)
                Text(
                  '${provider.faceEmbeddingResult[provider.embeddingStartIndex + 1]}',
                ),
              Text('Blur: ${provider.blurValue.round()}'),
            ],
          )
        else
          const SizedBox(height: 48),
        provider.embeddingStartIndex + 2 < provider.faceEmbeddingResult.length
            ? IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: provider.nextEmbedding,
        )
            : const SizedBox(height: 48),
      ],
    );
  }
}