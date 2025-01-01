import 'package:flutter/material.dart';
class CustomButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final ButtonSize size;

  const CustomButton({
    required this.icon,
    required this.label,
    this.onPressed,
    this.style,
    this.size = ButtonSize.normal,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: _getMinWidth,
        minHeight: _getMinHeight,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: _getPadding,
            vertical: _getPadding * 0.4,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: _getIconSize),
            SizedBox(width: _getPadding / 2),
            Text(
              label,
              style: TextStyle(fontSize: _getFontSize),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  double get _getMinWidth {
    switch (size) {
      case ButtonSize.xs: return 70;
      case ButtonSize.sm: return 80;
      case ButtonSize.normal: return 100;
      case ButtonSize.lg: return 120;
      case ButtonSize.xl: return 140;
    }
  }

  double get _getMinHeight {
    switch (size) {
      case ButtonSize.xs: return 24;
      case ButtonSize.sm: return 28;
      case ButtonSize.normal: return 32;
      case ButtonSize.lg: return 36;
      case ButtonSize.xl: return 40;
    }
  }

  double get _getPadding {
    switch (size) {
      case ButtonSize.xs: return 20;     // Doubled from 8
      case ButtonSize.sm: return 24;     // Doubled from 12
      case ButtonSize.normal: return 32;  // Doubled from 16
      case ButtonSize.lg: return 40;      // Doubled from 20
      case ButtonSize.xl: return 48;      // Doubled from 24
    }
  }

  double get _getIconSize {
    switch (size) {
      case ButtonSize.xs: return 12;
      case ButtonSize.sm: return 14;
      case ButtonSize.normal: return 20;
      case ButtonSize.lg: return 24;
      case ButtonSize.xl: return 28;
    }
  }

  double get _getFontSize {
    switch (size) {
      case ButtonSize.xs: return 10;
      case ButtonSize.sm: return 11;
      case ButtonSize.normal: return 12;
      case ButtonSize.lg: return 14;
      case ButtonSize.xl: return 16;
    }
  }
}

enum ButtonSize { xs, sm, normal, lg, xl }