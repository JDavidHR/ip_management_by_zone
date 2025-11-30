import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class BarLeft extends StatelessWidget {
  final ValueChanged<String> onItemSelected;

  const BarLeft({super.key, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: const Color.fromARGB(255, 31, 31, 31),
      child: Column(
        children: [
          DrawerHeader(
            child: Center(
              child: Image.asset(
                'assets/logos/MC_logo.png',
                width: 180,
                fit: BoxFit.contain,
              ),
            ),
          ),
          // _sectionTitle("Principal"),
          _buildMenuItem(
              'Eje Cafetero', LucideIcons.tableCellsMerge, onItemSelected),
          _buildMenuItem(
              'Medellin', LucideIcons.tableCellsMerge, onItemSelected),
          _buildMenuItem('Bogota', LucideIcons.tableCellsMerge, onItemSelected),
        ],
      ),
    );
  }

  // Widget _sectionTitle(String title) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  //     child: Text(
  //       title,
  //       style: const TextStyle(
  //         color: Colors.white60,
  //         fontSize: 13,
  //         fontWeight: FontWeight.bold,
  //       ),
  //     ),
  //   );
  // }

  Widget _buildMenuItem(
    String title,
    IconData icon,
    ValueChanged<String> onTap,
  ) {
    return InkWell(
      onTap: () => onTap(title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
