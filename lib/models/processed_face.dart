import 'dart:typed_data';

class ProcessedFace {
  final bool isRegistered;
  final int? registeredId;
  final String? name;
  final Uint8List alignedImage;
  final List<double> embedding;
  final double blurValue;
  final double? similarity;

  ProcessedFace({
    required this.isRegistered,
    this.registeredId,
    this.name,
    required this.alignedImage,
    required this.embedding,
    required this.blurValue,
    this.similarity,
  });
}