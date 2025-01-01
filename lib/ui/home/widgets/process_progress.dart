import 'package:flutter/material.dart';

class ProcessProgress extends StatelessWidget {
  final double progress;
  final String step;
  final Color? progressColor;
  final Color? backgroundColor;
  final EdgeInsets padding;

  const ProcessProgress({
    required this.progress,
    required this.step,
    this.progressColor,
    this.backgroundColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        children: [
          LinearProgressIndicator(
            value: progress,
            backgroundColor: backgroundColor ?? Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              progressColor ?? Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            step,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

