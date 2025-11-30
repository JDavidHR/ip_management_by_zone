import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mc_dashboard/core/colors.dart';
import 'package:mc_dashboard/dashboard/bar_left.dart';
import 'package:mc_dashboard/dashboard/top_header.dart';
import 'package:mc_dashboard/pages.dart/equipos_page.dart';
import 'package:mc_dashboard/pages.dart/pass_herramientas_page.dart';
import 'package:mc_dashboard/pages.dart/pass_rg_page.dart';

class DashboardBasePage extends StatefulWidget {
  const DashboardBasePage({super.key});

  @override
  State<DashboardBasePage> createState() => _DashboardBasePageState();
}

class _DashboardBasePageState extends State<DashboardBasePage> {
  Widget _selectedPage = const EquiposPage();

  void _onMenuItemSelected(String page) {
    setState(() {
      switch (page) {
        case 'Eje cafetero':
          _selectedPage = Container();
          break;
        case 'Medellin':
          _selectedPage = Container();
          break;
        case 'Bogota':
          _selectedPage = Container();
          break;
        default:
          _selectedPage = Center(
            child: Text(
              'Seleccione una sección',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
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
