import 'package:flutter/material.dart';
import 'package:mc_dashboard/core/colors.dart';

class McTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final TextInputType? keyboardType;
  final void Function(String)? onChanged;

  const McTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: MCPaletteColors.surface,
      ),
    );
  }
}
