
import 'package:flutter/material.dart';
import 'package:flutterface/ui/home/providers/face_detection_provider.dart';
import 'package:provider/provider.dart';

class PeriodSelector extends StatelessWidget {
  const PeriodSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FaceDetectionProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time, size: 20),
          const SizedBox(width: 4),
          DropdownButton<int>(
            value: provider.period,
            underline: Container(),
            items: [
              for (int i = 0; i < 24; i++)
                DropdownMenuItem(
                  value: i,
                  child: Text(
                    '${i.toString().padLeft(2, '0')}:00',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
            ],
            onChanged: (value) {
              if (value != null) {
                provider.updatePeriod(value);  // Using updatePeriod instead of setPeriod
              }
            },
          ),
        ],
      ),
    );
  }
}