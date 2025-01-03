import 'dart:developer' as devtools show log;

class ProgressHandler {
  Future<void> run(
      double progress,
      String message,
      void Function(double progress, String step)? onProgress,
      ) async {
    onProgress?.call(progress, message);
  }

  Future<void> updateProgress(
      int currentIndex,
      int totalFaces,
      void Function(double progress, String step)? onProgress,
      ) async {
    final progress = 0.3 + (0.6 * (currentIndex + 1) / totalFaces);
    onProgress?.call(
      progress,
      'Processing face ${currentIndex + 1} of $totalFaces',
    );
  }

  Future<void> complete(
      void Function(double progress, String step)? onProgress,
      ) async {
    onProgress?.call(0.9, 'Finalizing results...');
    await Future.delayed(const Duration(milliseconds: 200));
    onProgress?.call(1.0, 'Processing complete');
  }

  Future<void> handleError(dynamic error) async {
    devtools.log('Error during face processing: $error');
    throw Exception('Face processing failed: $error');
  }

  static const initialProgress = 0.1;
  static const detectionProgress = 0.3;
  static const processingRangeStart = 0.3;
  static const processingRangeEnd = 0.9;
  static const finalProgress = 1.0;
  static const finalizingDelay = Duration(milliseconds: 200);
}