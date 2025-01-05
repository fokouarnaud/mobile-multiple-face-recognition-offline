import 'package:flutter/material.dart';

class DragHandle extends StatelessWidget {

  const DragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        height: 4,
        width: 32,
        decoration: BoxDecoration(
          color: Colors.grey.withAlpha(63),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}