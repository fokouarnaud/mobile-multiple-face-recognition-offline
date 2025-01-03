class FaceMatch {
  final int id;
  final String name;
  final String imageHash;
  final double similarity;

  FaceMatch({
    required this.id,
    required this.name,
    required this.imageHash,
    required this.similarity,
  });
}