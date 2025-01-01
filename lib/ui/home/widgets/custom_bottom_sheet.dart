import 'package:flutter/material.dart';
import 'package:flutterface/ui/home/providers/face_detection_provider.dart';
import 'package:provider/provider.dart';

class CustomBottomSheet extends StatelessWidget {
  const CustomBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.2,
      minChildSize: 0.1,
      maxChildSize: 0.6,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(26),
                spreadRadius: 1,
                blurRadius: 10,
              ),
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Consumer<FaceDetectionProvider>(
                builder: (context, provider, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (provider.processingResult != null) ...[
                        _buildStatsGrid(provider),
                        const SizedBox(height: 24),
                        const Text(
                          'Detected Faces',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildFacesList(provider),
                      ] else ...[
                        Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.face_retouching_natural,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Click on "Detect faces" to start face detection',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsGrid(FaceDetectionProvider provider) {
    final stats = [
      {
        'title': 'Total Faces',
        'value': provider.processingResult!.processedFaces.length.toString(),
      },
      {
        'title': 'New Faces',
        'value': provider.processingResult!.processedFaces
            .where((face) => !face.isRegistered)
            .length
            .toString(),
      },
      {
        'title': 'Registered',
        'value': provider.processingResult!.processedFaces
            .where((face) => face.isRegistered)
            .length
            .toString(),
      },
    ];

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      childAspectRatio: 1.5,
      children: stats.map((stat) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  stat['value']!,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  stat['title']!,
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFacesList(FaceDetectionProvider provider) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.processingResult!.processedFaces.length,
      itemBuilder: (context, index) {
        final face = provider.processingResult!.processedFaces[index];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image.memory(
                face.alignedImage,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              face.name ?? 'Unregistered Face',
              style: const TextStyle(fontSize: 16),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: face.isRegistered
                    ? Colors.green.withAlpha(51)
                    : Colors.orange.withAlpha(51),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                face.isRegistered ? 'Registered' : 'New',
                style: TextStyle(
                  fontSize: 14,
                  color: face.isRegistered ? Colors.green : Colors.orange,
                ),
              ),
            ),
            onTap: () async {
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          face.alignedImage,
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        face.name ?? 'Unregistered Face',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
