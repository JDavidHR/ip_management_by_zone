import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mc_dashboard/core/colors.dart';
import 'package:mc_dashboard/pages.dart/tables/table_coffee_region_area.dart';

class DashboardBasePage extends StatefulWidget {
  const DashboardBasePage({super.key});

  @override
  State<DashboardBasePage> createState() => _DashboardBasePageState();
}

class _DashboardBasePageState extends State<DashboardBasePage> {
  Widget _selectedPage = const Center(
    child: Text(
      'Seleccione una sección',
      style: TextStyle(fontSize: 18, color: Colors.grey),
    ),
  );

  void _onMenuItemSelected(String page) {
    setState(() {
      switch (page) {
        case 'Eje Cafetero':
          _selectedPage = const TableCoffeeRegionArea();
          break;

        case 'Medellin':
          _selectedPage = const Center(
            child: Text(
              "Página Medellín (pendiente)",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
          break;

        case 'Bogota':
          _selectedPage = const Center(
            child: Text(
              "Página Bogotá (pendiente)",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
          break;

        default:
          _selectedPage = const Center(
            child: Text(
              'Seleccione una sección',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MCPaletteColors.background,
      body: Row(
        children: [
          BarLeft(onItemSelected: _onMenuItemSelected),
          Expanded(
            child: Column(
              children: [
                const TopHeader(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _selectedPage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TopHeader extends StatelessWidget {
  const TopHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 31, 31, 31),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: null,
                icon: const Icon(
                  LucideIcons.bell,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: null,
                icon: const Icon(
                  LucideIcons.settings,
                  color: Colors.white,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class BarLeft extends StatefulWidget {
  final Function(String) onItemSelected;

  const BarLeft({Key? key, required this.onItemSelected}) : super(key: key);

  @override
  State<BarLeft> createState() => _BarLeftState();
}

class _BarLeftState extends State<BarLeft> {
  bool _isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: _isCollapsed ? 70 : 250,
      color: const Color.fromARGB(255, 31, 31, 31),
      child: Column(
        children: [
          // === LOGO ===
          DrawerHeader(
            child: Center(
              child: _isCollapsed
                  ? const Icon(
                      Icons.window_rounded,
                      color: Colors.white,
                      size: 40,
                    )
                  : Image.asset(
                      'assets/logos/MC_logo.png',
                      width: 160,
                      fit: BoxFit.contain,
                    ),
            ),
          ),

          // === MENÚS ===
          Expanded(
            child: ListView(
              children: [
                _buildMenuItem('Eje Cafetero', LucideIcons.tableCellsMerge),
                _buildMenuItem('Medellín', LucideIcons.tableCellsMerge),
                _buildMenuItem('Bogotá', LucideIcons.tableCellsMerge),

                // === BOTÓN DE EXPANDIR / COLAPSAR ===
                Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 8, top: 8),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      _isCollapsed
                          ? LucideIcons.chevronRight
                          : LucideIcons.chevronLeft,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _isCollapsed = !_isCollapsed;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon) {
    return InkWell(
      onTap: () => widget.onItemSelected(title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.white),
            if (!_isCollapsed) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
