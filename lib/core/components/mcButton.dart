import 'package:flutter/material.dart';
import 'package:mc_dashboard/core/colors.dart';

class MCButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final Color? color;
  final Color textColor;
  final double? width;
  final double? height;

  const MCButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.color,
    this.textColor = Colors.white,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 50,
      height: height ?? 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? MCPaletteColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }
}
