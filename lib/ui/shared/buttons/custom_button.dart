import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? minWidth;
  final double? minHeight;

  const CustomButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.minWidth = 50,
    this.minHeight = 30,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(
        icon,
        size: 16,
        color: foregroundColor ?? Colors.black,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: foregroundColor ?? Colors.black,
          fontSize: 10,
        ),
      ),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(minWidth!, minHeight!),
        backgroundColor: backgroundColor ?? Colors.grey[200],
        foregroundColor: foregroundColor ?? Colors.black,
        elevation: 1,
      ),
    );
  }
}